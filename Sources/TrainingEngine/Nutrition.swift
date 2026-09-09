import Foundation

public enum MealType: String, CaseIterable, Codable, Sendable, Hashable {
    case breakfast
    case lunch
    case dinner
    case snack
    case other
}

public struct NutritionEntry: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let mealType: MealType
    public let calories: Double
    public let proteinGrams: Double
    public let carbsGrams: Double
    public let fatGrams: Double
    public let recordedAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        mealType: MealType = .other,
        calories: Double,
        proteinGrams: Double = 0,
        carbsGrams: Double = 0,
        fatGrams: Double = 0,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.mealType = mealType
        self.calories = max(0, calories)
        self.proteinGrams = max(0, proteinGrams)
        self.carbsGrams = max(0, carbsGrams)
        self.fatGrams = max(0, fatGrams)
        self.recordedAt = recordedAt
    }
}

public struct NutritionTarget: Codable, Sendable, Equatable {
    public let calories: Double
    public let proteinGrams: Double
    public let carbsGrams: Double
    public let fatGrams: Double

    public init(
        calories: Double = 0,
        proteinGrams: Double = 0,
        carbsGrams: Double = 0,
        fatGrams: Double = 0
    ) {
        self.calories = max(0, calories)
        self.proteinGrams = max(0, proteinGrams)
        self.carbsGrams = max(0, carbsGrams)
        self.fatGrams = max(0, fatGrams)
    }

    public static let unset = NutritionTarget()
}

public struct DailyNutritionSummary: Codable, Sendable, Equatable {
    public let day: Date
    public let calories: Double
    public let proteinGrams: Double
    public let carbsGrams: Double
    public let fatGrams: Double
    public let target: NutritionTarget
    public let entryCount: Int

    public func adherence(actual: Double, target: Double) -> Double? {
        guard target > 0 else { return nil }
        return actual / target
    }

    public var calorieAdherence: Double? { adherence(actual: calories, target: target.calories) }
    public var proteinAdherence: Double? { adherence(actual: proteinGrams, target: target.proteinGrams) }
    public var carbAdherence: Double? { adherence(actual: carbsGrams, target: target.carbsGrams) }
    public var fatAdherence: Double? { adherence(actual: fatGrams, target: target.fatGrams) }
}

public struct NutritionEngine: Sendable {
    public init() {}

    public func summary(
        entries: [NutritionEntry],
        target: NutritionTarget,
        on date: Date,
        calendar: Calendar = .current
    ) -> DailyNutritionSummary {
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let relevant = entries.filter { $0.recordedAt >= start && $0.recordedAt < end }

        return DailyNutritionSummary(
            day: start,
            calories: relevant.reduce(0) { $0 + $1.calories },
            proteinGrams: relevant.reduce(0) { $0 + $1.proteinGrams },
            carbsGrams: relevant.reduce(0) { $0 + $1.carbsGrams },
            fatGrams: relevant.reduce(0) { $0 + $1.fatGrams },
            target: target,
            entryCount: relevant.count
        )
    }
}
