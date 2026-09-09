import XCTest
@testable import TrainingEngine

final class CloudSyncTests: XCTestCase {
    func testSnapshotRoundTripsWithoutLosingStructuredState() throws {
        let now = Date(timeIntervalSince1970: 1_788_955_200)
        let trainingState = TrainingState(asOf: now, muscles: [])
        let nutritionContext = NutritionPeriodContext(
            dayCount: 7,
            daysWithEntries: 3,
            averageCaloriesOnLoggedDays: 2_100,
            averageProteinOnLoggedDays: 110,
            averageCalorieAdherence: 1.0,
            averageProteinAdherence: 0.95,
            target: NutritionTarget(calories: 2_100, proteinGrams: 115)
        )
        let context = CoachContext(
            asOf: now,
            trainingState: trainingState,
            recentWorkoutCount: 2,
            weightTrend14Days: nil,
            waistTrend30Days: nil,
            recentNutrition: nutritionContext
        )
        let review = WeeklyReview(
            generatedAt: now,
            confidence: .medium,
            headline: "Recent data is becoming actionable.",
            observations: []
        )
        let entry = NutritionEntry(
            name: "Lunch",
            mealType: .lunch,
            calories: 650,
            proteinGrams: 40,
            carbsGrams: 75,
            fatGrams: 18,
            recordedAt: now
        )

        let snapshot = CloudStateSnapshot(
            generatedAt: now,
            sessions: [],
            measurements: [],
            muscleTargets: [],
            nutritionEntries: [entry],
            nutritionTarget: nutritionContext.target,
            coachContext: context,
            weeklyReview: review
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(CloudStateSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
        XCTAssertNoThrow(try decoded.validate())
    }

    func testSnapshotRejectsUnknownSchemaVersion() {
        let now = Date(timeIntervalSince1970: 1_788_955_200)
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
        let snapshot = CloudStateSnapshot(
            schemaVersion: 999,
            generatedAt: now,
            sessions: [],
            measurements: [],
            muscleTargets: [],
            nutritionEntries: [],
            nutritionTarget: .unset,
            coachContext: context,
            weeklyReview: WeeklyReview(
                generatedAt: now,
                confidence: .low,
                headline: "Baseline",
                observations: []
            )
        )

        XCTAssertThrowsError(try snapshot.validate()) { error in
            XCTAssertEqual(error as? CloudSyncContractError, .unsupportedSchemaVersion(999))
        }
    }
}
