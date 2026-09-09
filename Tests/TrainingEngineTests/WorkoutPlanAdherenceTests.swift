import XCTest
@testable import TrainingEngine

final class WorkoutPlanAdherenceTests: XCTestCase {
    func testClassifiesAcceptedReplacedSkippedAndManualExercises() throws {
        let sessionID = UUID()
        let recordedAt = Date(timeIntervalSince1970: 2_000_000_000)

        let result = WorkoutPlanAdherenceEngine().evaluate(
            workoutSessionID: sessionID,
            plannedExerciseIDs: ["bench", "row", "curl"],
            outcomes: [
                WorkoutPlanOutcome(plannedExerciseID: "bench", completedExerciseID: "bench"),
                WorkoutPlanOutcome(plannedExerciseID: "row", completedExerciseID: "lat_pulldown"),
                WorkoutPlanOutcome(plannedExerciseID: nil, completedExerciseID: "cable_crunch")
            ],
            recordedAt: recordedAt
        )

        XCTAssertEqual(result.workoutSessionID, sessionID)
        XCTAssertEqual(result.acceptedPlannedExerciseIDs, ["bench"])
        XCTAssertEqual(result.replacedPlannedExerciseIDs, ["row"])
        XCTAssertEqual(result.skippedPlannedExerciseIDs, ["curl"])
        XCTAssertEqual(result.completedExerciseIDs, ["bench", "lat_pulldown", "cable_crunch"])
        XCTAssertEqual(try XCTUnwrap(result.acceptanceRatio), 1.0 / 3.0, accuracy: 0.0001)
    }

    func testNoGeneratedPlanHasNoAcceptanceRatio() {
        let result = WorkoutPlanAdherenceEngine().evaluate(
            workoutSessionID: UUID(),
            plannedExerciseIDs: [],
            outcomes: [WorkoutPlanOutcome(plannedExerciseID: nil, completedExerciseID: "squat")]
        )

        XCTAssertNil(result.acceptanceRatio)
        XCTAssertTrue(result.acceptedPlannedExerciseIDs.isEmpty)
        XCTAssertTrue(result.replacedPlannedExerciseIDs.isEmpty)
        XCTAssertTrue(result.skippedPlannedExerciseIDs.isEmpty)
    }
}
