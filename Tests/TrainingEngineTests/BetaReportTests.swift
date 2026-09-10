import XCTest
@testable import TrainingEngine

final class BetaReportTests: XCTestCase {
    func testReportUsesWeightedExerciseAcceptanceAndAggregatesReasons() throws {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        let workoutA = UUID()
        let workoutB = UUID()

        let adherence = [
            WorkoutPlanAdherence(
                workoutSessionID: workoutA,
                recordedAt: now,
                plannedExerciseIDs: ["a", "b", "c", "d"],
                completedExerciseIDs: ["a", "x", "c"],
                acceptedPlannedExerciseIDs: ["a", "c"],
                replacedPlannedExerciseIDs: ["b"],
                skippedPlannedExerciseIDs: ["d"]
            ),
            WorkoutPlanAdherence(
                workoutSessionID: workoutB,
                recordedAt: now,
                plannedExerciseIDs: ["e", "f"],
                completedExerciseIDs: ["e", "f"],
                acceptedPlannedExerciseIDs: ["e", "f"],
                replacedPlannedExerciseIDs: [],
                skippedPlannedExerciseIDs: []
            )
        ]

        let feedback = [
            WorkoutRecommendationFeedback(workoutSessionID: workoutA, rating: 3, reason: .tooLong, recordedAt: now),
            WorkoutRecommendationFeedback(workoutSessionID: workoutB, rating: 5, reason: .goodBalance, recordedAt: now)
        ]

        let report = BetaReportEngine().makeReport(
            completedWorkoutCount: 5,
            adherenceRecords: adherence,
            feedbackRecords: feedback,
            appVersion: "0.1.0",
            buildNumber: "1",
            generatedAt: now
        )

        XCTAssertEqual(report.completedWorkoutCount, 5)
        XCTAssertEqual(report.generatedWorkoutCount, 2)
        XCTAssertEqual(report.plannedExerciseCount, 6)
        XCTAssertEqual(report.acceptedExerciseCount, 4)
        XCTAssertEqual(report.replacedExerciseCount, 1)
        XCTAssertEqual(report.skippedExerciseCount, 1)
        XCTAssertEqual(try XCTUnwrap(report.exerciseAcceptanceRate), 4.0 / 6.0, accuracy: 0.0001)
        XCTAssertEqual(report.ratedWorkoutCount, 2)
        XCTAssertEqual(try XCTUnwrap(report.averageUsefulnessRating), 4.0, accuracy: 0.0001)
        XCTAssertEqual(try XCTUnwrap(report.favorableWorkoutRate), 0.5, accuracy: 0.0001)
        XCTAssertEqual(report.feedbackReasonCounts[WorkoutFeedbackReason.tooLong.rawValue], 1)
        XCTAssertEqual(report.feedbackReasonCounts[WorkoutFeedbackReason.goodBalance.rawValue], 1)
    }

    func testJSONContainsAggregatesWithoutSessionOrExerciseIdentifiers() throws {
        let workoutID = UUID()
        let report = BetaReportEngine().makeReport(
            completedWorkoutCount: 1,
            adherenceRecords: [
                WorkoutPlanAdherence(
                    workoutSessionID: workoutID,
                    recordedAt: Date(),
                    plannedExerciseIDs: ["secret_exercise_id"],
                    completedExerciseIDs: ["secret_exercise_id"],
                    acceptedPlannedExerciseIDs: ["secret_exercise_id"],
                    replacedPlannedExerciseIDs: [],
                    skippedPlannedExerciseIDs: []
                )
            ],
            feedbackRecords: [
                WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 5, reason: .goodBalance)
            ],
            appVersion: "0.1.0",
            buildNumber: "1"
        )

        let json = try XCTUnwrap(BetaReportEngine().encodeJSON(report))
        XCTAssertFalse(json.contains(workoutID.uuidString))
        XCTAssertFalse(json.contains("secret_exercise_id"))
        XCTAssertTrue(json.contains("acceptedExerciseCount"))
        XCTAssertTrue(json.contains("averageUsefulnessRating"))
    }

    func testEmptyReportKeepsRatesNilInsteadOfInventingZeroPerformance() {
        let report = BetaReportEngine().makeReport(
            completedWorkoutCount: 0,
            adherenceRecords: [],
            feedbackRecords: [],
            appVersion: "0.1.0",
            buildNumber: "1"
        )

        XCTAssertNil(report.exerciseAcceptanceRate)
        XCTAssertNil(report.averageUsefulnessRating)
        XCTAssertNil(report.favorableWorkoutRate)
    }
}
