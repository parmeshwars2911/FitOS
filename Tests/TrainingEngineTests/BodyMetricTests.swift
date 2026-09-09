import XCTest
@testable import TrainingEngine

final class BodyMetricTests: XCTestCase {
    func testTrendUsesLatestAndPreviousComparableMeasurement() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let measurements = [
            BodyMeasurement(kind: .weightKg, value: 58.0, recordedAt: now.addingTimeInterval(-3 * 86_400)),
            BodyMeasurement(kind: .waistCm, value: 78.0, recordedAt: now.addingTimeInterval(-2 * 86_400)),
            BodyMeasurement(kind: .weightKg, value: 58.4, recordedAt: now.addingTimeInterval(-86_400)),
            BodyMeasurement(kind: .weightKg, value: 58.6, recordedAt: now)
        ]

        let trend = BodyTrendEngine().trend(for: .weightKg, measurements: measurements, asOf: now)

        XCTAssertNotNil(trend)
        XCTAssertEqual(trend?.latestValue ?? 0, 58.6, accuracy: 0.0001)
        XCTAssertEqual(trend?.previousValue ?? 0, 58.4, accuracy: 0.0001)
        XCTAssertEqual(trend?.deltaFromPrevious ?? 0, 0.2, accuracy: 0.0001)
        XCTAssertEqual(trend?.observationCount, 3)
    }

    func testTrendWindowExcludesOldObservations() {
        let now = Date(timeIntervalSince1970: 3_000_000)
        let measurements = [
            BodyMeasurement(kind: .weightKg, value: 56.0, recordedAt: now.addingTimeInterval(-10 * 86_400)),
            BodyMeasurement(kind: .weightKg, value: 58.0, recordedAt: now.addingTimeInterval(-3 * 86_400)),
            BodyMeasurement(kind: .weightKg, value: 59.0, recordedAt: now.addingTimeInterval(-86_400))
        ]

        let trend = BodyTrendEngine().trend(for: .weightKg, measurements: measurements, windowDays: 7, asOf: now)

        XCTAssertEqual(trend?.observationCount, 2)
        XCTAssertEqual(trend?.averageValue ?? 0, 58.5, accuracy: 0.0001)
    }
}
