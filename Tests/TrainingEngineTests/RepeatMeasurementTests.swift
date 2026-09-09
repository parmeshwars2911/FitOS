import XCTest
@testable import TrainingEngine

final class RepeatMeasurementTests: XCTestCase {
    func testTapeMeasurementsUseMedian() throws {
        let result = try XCTUnwrap(
            RepeatMeasurementEngine().aggregate(
                kind: .waistCm,
                readings: [80.1, 84.7, 80.0]
            )
        )

        XCTAssertEqual(result, 80.1, accuracy: 0.0001)
    }

    func testWeightUsesMean() throws {
        let result = try XCTUnwrap(
            RepeatMeasurementEngine().aggregate(
                kind: .weightKg,
                readings: [58.0, 58.2]
            )
        )

        XCTAssertEqual(result, 58.1, accuracy: 0.0001)
    }

    func testRecommendedRepeatsAreHigherForTapeMeasurements() {
        let engine = RepeatMeasurementEngine()
        XCTAssertEqual(engine.recommendedRepeatCount(for: .weightKg), 1)
        XCTAssertEqual(engine.recommendedRepeatCount(for: .heightCm), 2)
        XCTAssertEqual(engine.recommendedRepeatCount(for: .waistCm), 3)
        XCTAssertEqual(engine.recommendedRepeatCount(for: .bicepsCm), 3)
    }

    func testInvalidReadingsAreIgnoredByCoreAggregator() throws {
        let result = try XCTUnwrap(
            RepeatMeasurementEngine().aggregate(
                kind: .bicepsCm,
                readings: [33.0, .nan, -1, 33.2]
            )
        )

        XCTAssertEqual(result, 33.1, accuracy: 0.0001)
    }
}
