import Foundation

public struct RepeatMeasurementEngine: Sendable {
    public init() {}

    public func recommendedRepeatCount(for kind: BodyMetricKind) -> Int {
        switch kind {
        case .weightKg:
            return 1
        case .heightCm, .bodyFatPercent:
            return 2
        case .waistCm, .chestCm, .bicepsCm, .thighCm:
            return 3
        }
    }

    public func aggregate(kind: BodyMetricKind, readings: [Double]) -> Double? {
        let valid = readings.filter { $0.isFinite && $0 > 0 }
        guard !valid.isEmpty else { return nil }

        switch kind {
        case .weightKg, .heightCm:
            return valid.reduce(0, +) / Double(valid.count)
        case .bodyFatPercent, .waistCm, .chestCm, .bicepsCm, .thighCm:
            return median(valid)
        }
    }

    private func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }
}
