import Foundation

public enum BodyMetricKind: String, CaseIterable, Codable, Sendable, Hashable {
    case weightKg
    case heightCm
    case bodyFatPercent
    case waistCm
    case chestCm
    case bicepsCm
    case thighCm
}

public struct BodyMeasurement: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let kind: BodyMetricKind
    public let value: Double
    public let recordedAt: Date

    public init(id: UUID = UUID(), kind: BodyMetricKind, value: Double, recordedAt: Date = Date()) {
        self.id = id
        self.kind = kind
        self.value = value
        self.recordedAt = recordedAt
    }
}

public struct BodyMetricTrend: Codable, Sendable, Equatable {
    public let kind: BodyMetricKind
    public let latestValue: Double
    public let previousValue: Double?
    public let averageValue: Double
    public let observationCount: Int
    public let firstRecordedAt: Date
    public let latestRecordedAt: Date

    public var deltaFromPrevious: Double? {
        guard let previousValue else { return nil }
        return latestValue - previousValue
    }

    public var percentChangeFromPrevious: Double? {
        guard let previousValue, previousValue != 0 else { return nil }
        return ((latestValue - previousValue) / previousValue) * 100
    }
}

public struct BodyTrendEngine: Sendable {
    public init() {}

    public func trend(
        for kind: BodyMetricKind,
        measurements: [BodyMeasurement],
        windowDays: Double? = nil,
        asOf: Date = Date()
    ) -> BodyMetricTrend? {
        var relevant = measurements.filter { measurement in
            guard measurement.kind == kind, measurement.recordedAt <= asOf else { return false }
            if let windowDays {
                let start = asOf.addingTimeInterval(-windowDays * 24 * 3600)
                return measurement.recordedAt >= start
            }
            return true
        }
        .sorted { $0.recordedAt < $1.recordedAt }

        guard let latest = relevant.last, let first = relevant.first else { return nil }
        let previous = relevant.dropLast().last
        let average = relevant.reduce(0.0) { $0 + $1.value } / Double(relevant.count)

        return BodyMetricTrend(
            kind: kind,
            latestValue: latest.value,
            previousValue: previous?.value,
            averageValue: average,
            observationCount: relevant.count,
            firstRecordedAt: first.recordedAt,
            latestRecordedAt: latest.recordedAt
        )
    }
}
