import XCTest
@testable import TrainingEngine

final class CoachContextTests: XCTestCase {
    func testContextCombinesWorkoutBodyAndNutritionHistory() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let day = calendar.startOfDay(for: now)

        let chest = ExerciseDefinition(
            id: "bench",
            name: "Bench Press",
            muscles: [MuscleContribution(.chest, factor: 1)],
            equipment: "barbell"
        )
        let sessions = [
            WorkoutSession(
                completedAt: now.addingTimeInterval(-86_400),
                exercises: [CompletedExercise(exercise: chest, sets: [CompletedSet(reps: 8, loadKg: 50, rir: 2)])]
            )
        ]
        let trainingState = TrainingStateEngine().evaluate(
            sessions: sessions,
            targets: [MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 8)],
            asOf: now
        )
        let measurements = [
            BodyMeasurement(kind: .weightKg, value: 58.0, recordedAt: now.addingTimeInterval(-4 * 86_400)),
            BodyMeasurement(kind: .weightKg, value: 58.4, recordedAt: now.addingTimeInterval(-86_400))
        ]
        let nutrition = [
            NutritionEntry(name: "Day one", calories: 2_000, proteinGrams: 100, recordedAt: day.addingTimeInterval(12 * 3600)),
            NutritionEntry(name: "Day two", calories: 2_200, proteinGrams: 120, recordedAt: day.addingTimeInterval(-86_400 + 12 * 3600))
        ]

        let context = CoachContextEngine().build(
            trainingState: trainingState,
            sessions: sessions,
            measurements: measurements,
            nutritionEntries: nutrition,
            nutritionTarget: NutritionTarget(calories: 2_200, proteinGrams: 120),
            asOf: now,
            calendar: calendar
        )

        XCTAssertEqual(context.recentWorkoutCount, 1)
        XCTAssertEqual(context.weightTrend14Days?.observationCount, 2)
        XCTAssertEqual(context.recentNutrition.daysWithEntries, 2)
        XCTAssertEqual(context.recentNutrition.averageProteinOnLoggedDays ?? 0, 110, accuracy: 0.0001)
    }

    func testReviewFlagsRecoveredTrainingDebtAndLowProtein() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let muscleState = MuscleState(
            muscle: .triceps,
            effectiveSets: 2,
            targetSets: 10,
            deficitSets: 8,
            recovery: 1,
            priorityScore: 0.8,
            lastStimulatedAt: nil
        )
        let context = CoachContext(
            asOf: now,
            trainingState: TrainingState(asOf: now, muscles: [muscleState]),
            recentWorkoutCount: 3,
            weightTrend14Days: nil,
            waistTrend30Days: nil,
            recentNutrition: NutritionPeriodContext(
                dayCount: 7,
                daysWithEntries: 5,
                averageCaloriesOnLoggedDays: 2_000,
                averageProteinOnLoggedDays: 80,
                averageCalorieAdherence: 0.91,
                averageProteinAdherence: 0.67,
                target: NutritionTarget(calories: 2_200, proteinGrams: 120)
            )
        )

        let review = WeeklyReviewEngine().review(context: context)
        let ids = Set(review.observations.map(\.id))

        XCTAssertTrue(ids.contains("training-debt"))
        XCTAssertTrue(ids.contains("protein-below-target"))
        XCTAssertEqual(review.confidence, .medium)
    }

    func testSparseHistoryProducesLowConfidence() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let context = CoachContext(
            asOf: now,
            trainingState: TrainingState(asOf: now, muscles: []),
            recentWorkoutCount: 0,
            weightTrend14Days: nil,
            waistTrend30Days: nil,
            recentNutrition: NutritionPeriodContext(
                dayCount: 7,
                daysWithEntries: 0,
                averageCaloriesOnLoggedDays: nil,
                averageProteinOnLoggedDays: nil,
                averageCalorieAdherence: nil,
                averageProteinAdherence: nil,
                target: .unset
            )
        )

        let review = WeeklyReviewEngine().review(context: context)
        XCTAssertEqual(review.confidence, .low)
        XCTAssertTrue(review.observations.contains { $0.id == "nutrition-coverage" })
    }
}
