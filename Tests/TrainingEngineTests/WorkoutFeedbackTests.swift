import XCTest
@testable import TrainingEngine

final class WorkoutFeedbackTests: XCTestCase {
    func testRatingIsClampedToOneThroughFive() {
        let workoutID = UUID()
        XCTAssertEqual(WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 0).rating, 1)
        XCTAssertEqual(WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 8).rating, 5)
    }

    func testSummaryCalculatesAverageAndFavorableRate() {
        let workoutID = UUID()
        let records = [
            WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 5),
            WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 4),
            WorkoutRecommendationFeedback(workoutSessionID: workoutID, rating: 2)
        ]

        let summary = WorkoutFeedbackEngine().summary(records)
        XCTAssertEqual(summary.ratingCount, 3)
        XCTAssertEqual(summary.averageRating ?? 0, 11.0 / 3.0, accuracy: 0.0001)
        XCTAssertEqual(summary.favorableCount, 2)
        XCTAssertEqual(summary.favorableRate ?? 0, 2.0 / 3.0, accuracy: 0.0001)
    }
}
