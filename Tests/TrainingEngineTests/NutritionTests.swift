import XCTest
@testable import TrainingEngine

final class NutritionTests: XCTestCase {
    func testDailySummarySumsOnlySelectedDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let day = Date(timeIntervalSince1970: 1_800_000_000)
        let start = calendar.startOfDay(for: day)

        let entries = [
            NutritionEntry(name: "Eggs", mealType: .breakfast, calories: 240, proteinGrams: 18, carbsGrams: 2, fatGrams: 16, recordedAt: start.addingTimeInterval(8 * 3600)),
            NutritionEntry(name: "Chicken rice", mealType: .lunch, calories: 620, proteinGrams: 45, carbsGrams: 80, fatGrams: 12, recordedAt: start.addingTimeInterval(13 * 3600)),
            NutritionEntry(name: "Tomorrow", calories: 500, proteinGrams: 30, recordedAt: start.addingTimeInterval(26 * 3600))
        ]

        let target = NutritionTarget(calories: 2_200, proteinGrams: 120, carbsGrams: 260, fatGrams: 65)
        let summary = NutritionEngine().summary(entries: entries, target: target, on: day, calendar: calendar)

        XCTAssertEqual(summary.entryCount, 2)
        XCTAssertEqual(summary.calories, 860, accuracy: 0.0001)
        XCTAssertEqual(summary.proteinGrams, 63, accuracy: 0.0001)
        XCTAssertEqual(summary.carbsGrams, 82, accuracy: 0.0001)
        XCTAssertEqual(summary.fatGrams, 28, accuracy: 0.0001)
    }

    func testAdherenceIsNilUntilTargetIsSet() {
        let summary = NutritionEngine().summary(entries: [], target: .unset, on: Date())
        XCTAssertNil(summary.calorieAdherence)
        XCTAssertNil(summary.proteinAdherence)
    }
}
