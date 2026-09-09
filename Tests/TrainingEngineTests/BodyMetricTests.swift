import XCTest
@testable import TrainingEngine

final class BodyMetricTests: XCTestCase {
    func testTrendKeepsRawValuesAndAddsSmoothedWeightSignal() {
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
        XCTAssertEqual(trend?.smoothedValue ?? 0, 58.333333, accuracy: 0.0001)
        XCTAssertEqual(trend?.previousSmoothedValue ?? 0, 58.2, accuracy: 0.0001)
        XCTAssertEqual(trend?.smoothedDelta ?? 0, 0.133333, accuracy: 0.0001)
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
        XCTAssertEqual(trend?.smoothedValue ?? 0, 58.5, accuracy: 0.0001)
    }

    func testSingleBadWaistReadingDoesNotBecomeFiveCentimeterTrend() {
        let now = Date(timeIntervalSince1970: 4_000_000)
        let measurements = [
            BodyMeasurement(kind: .waistCm, value: 80.0, recordedAt: now.addingTimeInterval(-2 * 86_400)),
            BodyMeasurement(kind: .waistCm, value: 80.2, recordedAt: now.addingTimeInterval(-86_400)),
            BodyMeasurement(kind: .waistCm, value: 85.0, recordedAt: now)
        ]

        let trend = BodyTrendEngine().trend(for: .waistCm, measurements: measurements, asOf: now)

        XCTAssertEqual(trend?.latestValue ?? 0, 85.0, accuracy: 0.0001)
        XCTAssertEqual(trend?.deltaFromPrevious ?? 0, 4.8, accuracy: 0.0001)
        XCTAssertEqual(trend?.smoothedValue ?? 0, 80.2, accuracy: 0.0001)
        XCTAssertEqual(trend?.previousSmoothedValue ?? 0, 80.1, accuracy: 0.0001)
        XCTAssertEqual(trend?.smoothedDelta ?? 0, 0.1, accuracy: 0.0001)
        XCTAssertEqual(trend?.confidence, .medium)
    }

    func testStableRepeatedTapeMeasurementsReachHighConfidence() {
        let now = Date(timeIntervalSince1970: 5_000_000)
        let values = [80.0, 80.1, 79.9, 80.0, 80.1]
        let measurements = values.enumerated().map { index, value in
            BodyMeasurement(
                kind: .waistCm,
                value: value,
                recordedAt: now.addingTimeInterval(Double(index - values.count + 1) * 86_400)
            )
        }

        let trend = BodyTrendEngine().trend(for: .waistCm, measurements: measurements, asOf: now)

        XCTAssertEqual(trend?.confidence, .high)
        XCTAssertLessThanOrEqual(trend?.variability ?? 99, 0.1)
    }

    func testSmoothedSeriesKeepsRawOutlierVisibleButTrendStable() throws {
        let now = Date(timeIntervalSince1970: 6_000_000)
        let measurements = [
            BodyMeasurement(kind: .bicepsCm, value: 33.0, recordedAt: now.addingTimeInterval(-2 * 86_400)),
            BodyMeasurement(kind: .bicepsCm, value: 33.1, recordedAt: now.addingTimeInterval(-86_400)),
            BodyMeasurement(kind: .bicepsCm, value: 34.4, recordedAt: now)
        ]

        let points = BodyTrendEngine().smoothedSeries(for: .bicepsCm, measurements: measurements, asOf: now)
        let last = try XCTUnwrap(points.last)

        XCTAssertEqual(last.rawValue, 34.4, accuracy: 0.0001)
        XCTAssertEqual(last.smoothedValue, 33.1, accuracy: 0.0001)
    }
}
