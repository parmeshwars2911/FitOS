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

public enum BodyMeasurementSource: String, Codable, Sendable, Equatable {
    case manual
    case healthKit
}

public struct BodyMeasurement: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let kind: BodyMetricKind
    public let value: Double
    public let recordedAt: Date
    public let source: BodyMeasurementSource?
    public let externalID: String?

    public init(
        id: UUID = UUID(),
        kind: BodyMetricKind,
        value: Double,
        recordedAt: Date = Date(),
        source: BodyMeasurementSource? = .manual,
        externalID: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.value = value
        self.recordedAt = recordedAt
        self.source = source
        self.externalID = externalID
    }
}

public enum BodyTrendConfidence: String, Codable, Sendable, Equatable {
    case low
    case medium
    case high
}

public struct BodyTrendPoint: Codable, Sendable, Equatable, Identifiable {
    public let recordedAt: Date
    public let rawValue: Double
    public let smoothedValue: Double

    public var id: Date { recordedAt }

    public init(recordedAt: Date, rawValue: Double, smoothedValue: Double) {
        self.recordedAt = recordedAt
        self.rawValue = rawValue
        self.smoothedValue = smoothedValue
    }
}

public struct BodyMetricTrend: Codable, Sendable, Equatable {
    public let kind: BodyMetricKind
    public let latestValue: Double
    public let previousValue: Double?
    public let averageValue: Double
    public let smoothedValue: Double
    public let previousSmoothedValue: Double?
    public let variability: Double
    public let confidence: BodyTrendConfidence
    public let observationCount: Int
    public let firstRecordedAt: Date
    public let latestRecordedAt: Date

    public var deltaFromPrevious: Double? {
        guard let previousValue else { return nil }
        return latestValue - previousValue
    }

    public var smoothedDelta: Double? {
        guard let previousSmoothedValue else { return nil }
        return smoothedValue - previousSmoothedValue
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
        let relevant = relevantMeasurements(
            for: kind,
            measurements: measurements,
            windowDays: windowDays,
            asOf: asOf
        )

        guard let latest = relevant.last, let first = relevant.first else { return nil }
        let previous = relevant.dropLast().last
        let average = relevant.reduce(0.0) { $0 + $1.value } / Double(relevant.count)
        let currentSample = smoothingSample(from: relevant, kind: kind)
        let previousMeasurements = Array(relevant.dropLast())
        let previousSample = smoothingSample(from: previousMeasurements, kind: kind)
        let currentSmoothed = smooth(values: currentSample.map(\.value), kind: kind)
        let previousSmoothed = previousSample.isEmpty ? nil : smooth(values: previousSample.map(\.value), kind: kind)
        let variability = noiseEstimate(values: currentSample.map(\.value), kind: kind)

        return BodyMetricTrend(
            kind: kind,
            latestValue: latest.value,
            previousValue: previous?.value,
            averageValue: average,
            smoothedValue: currentSmoothed,
            previousSmoothedValue: previousSmoothed,
            variability: variability,
            confidence: confidence(kind: kind, observationCount: relevant.count, variability: variability),
            observationCount: relevant.count,
            firstRecordedAt: first.recordedAt,
            latestRecordedAt: latest.recordedAt
        )
    }

    public func smoothedSeries(
        for kind: BodyMetricKind,
        measurements: [BodyMeasurement],
        maxPoints: Int = 12,
        asOf: Date = Date()
    ) -> [BodyTrendPoint] {
        let relevant = relevantMeasurements(for: kind, measurements: measurements, windowDays: nil, asOf: asOf)
        guard !relevant.isEmpty else { return [] }

        let points = relevant.indices.map { index -> BodyTrendPoint in
            let prefix = Array(relevant[...index])
            let sample = smoothingSample(from: prefix, kind: kind)
            return BodyTrendPoint(
                recordedAt: relevant[index].recordedAt,
                rawValue: relevant[index].value,
                smoothedValue: smooth(values: sample.map(\.value), kind: kind)
            )
        }
        return Array(points.suffix(max(1, maxPoints)))
    }

    private func relevantMeasurements(
        for kind: BodyMetricKind,
        measurements: [BodyMeasurement],
        windowDays: Double?,
        asOf: Date
    ) -> [BodyMeasurement] {
        measurements.filter { measurement in
            guard measurement.kind == kind, measurement.recordedAt <= asOf else { return false }
            if let windowDays {
                let start = asOf.addingTimeInterval(-windowDays * 24 * 3600)
                return measurement.recordedAt >= start
            }
            return true
        }
        .sorted { $0.recordedAt < $1.recordedAt }
    }

    private func smoothingSample(from measurements: [BodyMeasurement], kind: BodyMetricKind) -> [BodyMeasurement] {
        let count = min(measurements.count, smoothingWindow(for: kind))
        guard count > 0 else { return [] }
        return Array(measurements.suffix(count))
    }

    private func smoothingWindow(for kind: BodyMetricKind) -> Int {
        switch kind {
        case .weightKg:
            return 7
        case .heightCm:
            return 3
        case .bodyFatPercent, .waistCm, .chestCm, .bicepsCm, .thighCm:
            return 3
        }
    }

    private func smooth(values: [Double], kind: BodyMetricKind) -> Double {
        guard !values.isEmpty else { return 0 }
        if kind == .weightKg {
            return values.reduce(0, +) / Double(values.count)
        }
        return median(values)
    }

    private func noiseEstimate(values: [Double], kind: BodyMetricKind) -> Double {
        guard values.count > 1 else { return 0 }
        if kind == .weightKg {
            let mean = values.reduce(0, +) / Double(values.count)
            let variance = values.reduce(0.0) { partial, value in
                partial + pow(value - mean, 2)
            } / Double(values.count)
            return sqrt(variance)
        }

        let center = median(values)
        return median(values.map { abs($0 - center) })
    }

    private func confidence(kind: BodyMetricKind, observationCount: Int, variability: Double) -> BodyTrendConfidence {
        guard observationCount >= 3 else { return .low }
        let ratio = variability / max(0.0001, expectedNoise(for: kind))
        if observationCount >= 5, ratio <= 0.75 { return .high }
        if ratio <= 1.5 { return .medium }
        return .low
    }

    private func expectedNoise(for kind: BodyMetricKind) -> Double {
        switch kind {
        case .weightKg: return 0.7
        case .heightCm: return 0.5
        case .bodyFatPercent: return 1.5
        case .waistCm, .chestCm, .bicepsCm, .thighCm: return 1.0
        }
    }

    private func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }
}
