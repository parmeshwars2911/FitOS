import Foundation
import HealthKit

struct RecoverySnapshot: Equatable {
    let recentSleepHours: Double?
    let restingHeartRateBPM: Double?
    let heartRateVariabilityMS: Double?
    let syncedAt: Date
}

enum HealthKitServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "Apple Health is not available on this device."
        }
    }
}

@MainActor
final class HealthKitService {
    private let healthStore = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitServiceError.unavailable }
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func fetchBodyMeasurements(since startDate: Date) async throws -> [BodyMeasurement] {
        var result: [BodyMeasurement] = []

        result += try await bodyMeasurements(
            identifier: .bodyMass,
            kind: .weightKg,
            unit: .gramUnit(with: .kilo),
            since: startDate
        )
        result += try await bodyMeasurements(
            identifier: .height,
            kind: .heightCm,
            unit: .meterUnit(with: .centi),
            since: startDate
        )
        result += try await bodyMeasurements(
            identifier: .waistCircumference,
            kind: .waistCm,
            unit: .meterUnit(with: .centi),
            since: startDate
        )

        let bodyFatSamples = try await quantitySamples(identifier: .bodyFatPercentage, since: startDate, limit: 200)
        result += bodyFatSamples.map { sample in
            BodyMeasurement(
                kind: .bodyFatPercent,
                value: sample.quantity.doubleValue(for: .percent()) * 100,
                recordedAt: sample.endDate,
                source: .healthKit,
                externalID: sample.uuid.uuidString
            )
        }

        return result
    }

    func fetchRecoverySnapshot(asOf: Date = Date()) async throws -> RecoverySnapshot {
        let sevenDaysAgo = asOf.addingTimeInterval(-7 * 24 * 3600)
        let sleepStart = asOf.addingTimeInterval(-36 * 3600)

        let restingHR = try await latestQuantityValue(
            identifier: .restingHeartRate,
            unit: .count().unitDivided(by: .minute()),
            since: sevenDaysAgo
        )
        let hrv = try await latestQuantityValue(
            identifier: .heartRateVariabilitySDNN,
            unit: .secondUnit(with: .milli),
            since: sevenDaysAgo
        )
        let sleep = try await recentSleepHours(since: sleepStart, until: asOf)

        return RecoverySnapshot(
            recentSleepHours: sleep,
            restingHeartRateBPM: restingHR,
            heartRateVariabilityMS: hrv,
            syncedAt: asOf
        )
    }

    private var readTypes: Set<HKObjectType> {
        let types: [HKObjectType?] = [
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .height),
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
            HKObjectType.quantityType(forIdentifier: .waistCircumference),
            HKObjectType.quantityType(forIdentifier: .restingHeartRate),
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        ]
        return Set(types.compactMap { $0 })
    }

    private func bodyMeasurements(
        identifier: HKQuantityTypeIdentifier,
        kind: BodyMetricKind,
        unit: HKUnit,
        since startDate: Date
    ) async throws -> [BodyMeasurement] {
        let samples = try await quantitySamples(identifier: identifier, since: startDate, limit: 200)
        return samples.map { sample in
            BodyMeasurement(
                kind: kind,
                value: sample.quantity.doubleValue(for: unit),
                recordedAt: sample.endDate,
                source: .healthKit,
                externalID: sample.uuid.uuidString
            )
        }
    }

    private func latestQuantityValue(
        identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        since startDate: Date
    ) async throws -> Double? {
        let samples = try await quantitySamples(identifier: identifier, since: startDate, limit: 1)
        return samples.first?.quantity.doubleValue(for: unit)
    }

    private func quantitySamples(
        identifier: HKQuantityTypeIdentifier,
        since startDate: Date,
        limit: Int
    ) async throws -> [HKQuantitySample] {
        guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return [] }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: limit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKQuantitySample]) ?? [])
            }
            healthStore.execute(query)
        }
    }

    private func recentSleepHours(since startDate: Date, until endDate: Date) async throws -> Double? {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let samples: [HKCategorySample] = try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        let asleepValues: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue
        ]

        let intervals = samples
            .filter { asleepValues.contains($0.value) }
            .map { ($0.startDate, $0.endDate) }
            .sorted { $0.0 < $1.0 }

        guard var current = intervals.first else { return nil }
        var total: TimeInterval = 0

        for interval in intervals.dropFirst() {
            if interval.0 <= current.1 {
                current.1 = max(current.1, interval.1)
            } else {
                total += current.1.timeIntervalSince(current.0)
                current = interval
            }
        }
        total += current.1.timeIntervalSince(current.0)
        return total / 3600
    }
}
