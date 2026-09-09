import XCTest
@testable import TrainingEngine

final class AIContextExportTests: XCTestCase {
    func testAIContextExportRoundTripsAsVersionedJSON() throws {
        let now = Date(timeIntervalSince1970: 1_788_955_200)
        let context = CoachContext(
            asOf: now,
            trainingState: TrainingState(asOf: now, muscles: []),
            recentWorkoutCount: 2,
            weightTrend14Days: nil,
            waistTrend30Days: nil,
            recentNutrition: NutritionPeriodContext(
                dayCount: 7,
                daysWithEntries: 4,
                averageCaloriesOnLoggedDays: 2_200,
                averageProteinOnLoggedDays: 115,
                averageCalorieAdherence: 1.0,
                averageProteinAdherence: 1.0,
                target: NutritionTarget(calories: 2_200, proteinGrams: 115)
            )
        )
        let review = WeeklyReview(
            generatedAt: now,
            confidence: .medium,
            headline: "Useful recent data.",
            observations: []
        )
        let export = AIContextExport(generatedAt: now, coachContext: context, weeklyReview: review)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(export)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(AIContextExport.self, from: data)

        XCTAssertEqual(decoded, export)
        XCTAssertEqual(decoded.schemaVersion, AIContextExport.currentSchemaVersion)
    }
}
