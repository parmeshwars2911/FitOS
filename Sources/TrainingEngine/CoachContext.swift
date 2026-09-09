import Foundation

public enum CoachDataConfidence: String, Codable, Sendable, Equatable {
    case low
    case medium
    case high
}

public struct NutritionPeriodContext: Codable, Sendable, Equatable {
    public let dayCount: Int
    public let daysWithEntries: Int
    public let averageCaloriesOnLoggedDays: Double?
    public let averageProteinOnLoggedDays: Double?
    public let averageCalorieAdherence: Double?
    public let averageProteinAdherence: Double?
    public let target: NutritionTarget

    public init(
        dayCount: Int,
        daysWithEntries: Int,
        averageCaloriesOnLoggedDays: Double?,
        averageProteinOnLoggedDays: Double?,
        averageCalorieAdherence: Double?,
        averageProteinAdherence: Double?,
        target: NutritionTarget
    ) {
        self.dayCount = dayCount
        self.daysWithEntries = daysWithEntries
        self.averageCaloriesOnLoggedDays = averageCaloriesOnLoggedDays
        self.averageProteinOnLoggedDays = averageProteinOnLoggedDays
        self.averageCalorieAdherence = averageCalorieAdherence
        self.averageProteinAdherence = averageProteinAdherence
        self.target = target
    }
}

public struct CoachContext: Codable, Sendable, Equatable {
    public let asOf: Date
    public let trainingState: TrainingState
    public let recentWorkoutCount: Int
    public let weightTrend14Days: BodyMetricTrend?
    public let waistTrend30Days: BodyMetricTrend?
    public let recentNutrition: NutritionPeriodContext

    public init(
        asOf: Date,
        trainingState: TrainingState,
        recentWorkoutCount: Int,
        weightTrend14Days: BodyMetricTrend?,
        waistTrend30Days: BodyMetricTrend?,
        recentNutrition: NutritionPeriodContext
    ) {
        self.asOf = asOf
        self.trainingState = trainingState
        self.recentWorkoutCount = recentWorkoutCount
        self.weightTrend14Days = weightTrend14Days
        self.waistTrend30Days = waistTrend30Days
        self.recentNutrition = recentNutrition
    }
}

public enum CoachObservationKind: String, Codable, Sendable, Equatable {
    case positive
    case attention
    case information
}

public struct CoachObservation: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let kind: CoachObservationKind
    public let title: String
    public let message: String

    public init(id: String, kind: CoachObservationKind, title: String, message: String) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
    }
}

public struct WeeklyReview: Codable, Sendable, Equatable {
    public let generatedAt: Date
    public let confidence: CoachDataConfidence
    public let headline: String
    public let observations: [CoachObservation]

    public init(
        generatedAt: Date,
        confidence: CoachDataConfidence,
        headline: String,
        observations: [CoachObservation]
    ) {
        self.generatedAt = generatedAt
        self.confidence = confidence
        self.headline = headline
        self.observations = observations
    }
}

public struct CoachContextEngine: Sendable {
    public init() {}

    public func build(
        trainingState: TrainingState,
        sessions: [WorkoutSession],
        measurements: [BodyMeasurement],
        nutritionEntries: [NutritionEntry],
        nutritionTarget: NutritionTarget,
        asOf: Date = Date(),
        calendar: Calendar = .current
    ) -> CoachContext {
        let sevenDaysAgo = asOf.addingTimeInterval(-7 * 24 * 3600)
        let recentWorkoutCount = sessions.filter {
            $0.completedAt >= sevenDaysAgo && $0.completedAt <= asOf
        }.count

        let bodyEngine = BodyTrendEngine()
        let weightTrend = bodyEngine.trend(
            for: .weightKg,
            measurements: measurements,
            windowDays: 14,
            asOf: asOf
        )
        let waistTrend = bodyEngine.trend(
            for: .waistCm,
            measurements: measurements,
            windowDays: 30,
            asOf: asOf
        )

        let nutrition = nutritionPeriod(
            entries: nutritionEntries,
            target: nutritionTarget,
            asOf: asOf,
            calendar: calendar
        )

        return CoachContext(
            asOf: asOf,
            trainingState: trainingState,
            recentWorkoutCount: recentWorkoutCount,
            weightTrend14Days: weightTrend,
            waistTrend30Days: waistTrend,
            recentNutrition: nutrition
        )
    }

    private func nutritionPeriod(
        entries: [NutritionEntry],
        target: NutritionTarget,
        asOf: Date,
        calendar: Calendar
    ) -> NutritionPeriodContext {
        let nutritionEngine = NutritionEngine()
        let today = calendar.startOfDay(for: asOf)
        var summaries: [DailyNutritionSummary] = []

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            summaries.append(
                nutritionEngine.summary(entries: entries, target: target, on: day, calendar: calendar)
            )
        }

        let logged = summaries.filter { $0.entryCount > 0 }
        let averageCalories = average(logged.map(\.calories))
        let averageProtein = average(logged.map(\.proteinGrams))
        let calorieAdherence = average(logged.compactMap(\.calorieAdherence))
        let proteinAdherence = average(logged.compactMap(\.proteinAdherence))

        return NutritionPeriodContext(
            dayCount: summaries.count,
            daysWithEntries: logged.count,
            averageCaloriesOnLoggedDays: averageCalories,
            averageProteinOnLoggedDays: averageProtein,
            averageCalorieAdherence: calorieAdherence,
            averageProteinAdherence: proteinAdherence,
            target: target
        )
    }

    private func average(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }
}

public struct WeeklyReviewEngine: Sendable {
    public init() {}

    public func review(context: CoachContext) -> WeeklyReview {
        var observations: [CoachObservation] = []

        let priorityMuscles = context.trainingState.muscles
            .filter { $0.deficitSets >= 1.5 && $0.recovery >= 0.70 && $0.priorityScore >= 0.15 }
            .prefix(3)

        if !priorityMuscles.isEmpty {
            let labels = priorityMuscles.map { muscleName($0.muscle) }.joined(separator: ", ")
            observations.append(
                CoachObservation(
                    id: "training-debt",
                    kind: .attention,
                    title: "Recovered training debt",
                    message: "\(labels) are below their rolling targets and sufficiently recovered to deserve priority in upcoming sessions."
                )
            )
        } else if context.recentWorkoutCount > 0 {
            observations.append(
                CoachObservation(
                    id: "training-balanced",
                    kind: .positive,
                    title: "Training coverage",
                    message: "No large recovered muscle deficit stands out from the current rolling targets."
                )
            )
        }

        let nutrition = context.recentNutrition
        if nutrition.daysWithEntries < 3 {
            observations.append(
                CoachObservation(
                    id: "nutrition-coverage",
                    kind: .information,
                    title: "More nutrition data needed",
                    message: "Only \(nutrition.daysWithEntries) of the last 7 days contain nutrition entries. Log at least 3 days before treating nutrition patterns as meaningful."
                )
            )
        } else if let protein = nutrition.averageProteinAdherence, protein < 0.80 {
            observations.append(
                CoachObservation(
                    id: "protein-below-target",
                    kind: .attention,
                    title: "Protein below your target",
                    message: "Across logged days, protein averaged about \(Int((protein * 100).rounded()))% of the target you set."
                )
            )
        } else if let protein = nutrition.averageProteinAdherence, protein >= 0.95 {
            observations.append(
                CoachObservation(
                    id: "protein-on-target",
                    kind: .positive,
                    title: "Protein consistency",
                    message: "Across logged days, protein averaged about \(Int((protein * 100).rounded()))% of your target."
                )
            )
        }

        if let trend = context.weightTrend14Days, trend.observationCount >= 2,
           let firstDelta = trend.previousValue.map({ trend.latestValue - $0 }) {
            observations.append(
                CoachObservation(
                    id: "weight-trend",
                    kind: .information,
                    title: "Recent weight movement",
                    message: "Your latest weight is \(signed(firstDelta)) kg versus the previous observation. FitOS records the movement without assuming it is muscle or fat."
                )
            )
        }

        if observations.isEmpty {
            observations.append(
                CoachObservation(
                    id: "collect-data",
                    kind: .information,
                    title: "Build your baseline",
                    message: "Keep logging workouts, body measurements and nutrition. FitOS will become more specific as your history grows."
                )
            )
        }

        let confidence = confidence(for: context)
        let headline: String
        switch confidence {
        case .low:
            headline = "FitOS is still learning your baseline."
        case .medium:
            headline = "Your recent data is becoming actionable."
        case .high:
            headline = "FitOS has enough recent data for a stronger weekly read."
        }

        return WeeklyReview(
            generatedAt: context.asOf,
            confidence: confidence,
            headline: headline,
            observations: observations
        )
    }

    private func confidence(for context: CoachContext) -> CoachDataConfidence {
        var score = 0
        if context.recentWorkoutCount >= 2 { score += 1 }
        if context.recentNutrition.daysWithEntries >= 3 { score += 1 }
        if (context.weightTrend14Days?.observationCount ?? 0) >= 2 { score += 1 }

        switch score {
        case 3: return .high
        case 2: return .medium
        default: return .low
        }
    }

    private func signed(_ value: Double) -> String {
        String(format: "%+.1f", value)
    }

    private func muscleName(_ muscle: MuscleGroup) -> String {
        switch muscle {
        case .chest: return "chest"
        case .back: return "back"
        case .frontDelts: return "front delts"
        case .sideDelts: return "side delts"
        case .rearDelts: return "rear delts"
        case .triceps: return "triceps"
        case .biceps: return "biceps"
        case .traps: return "traps"
        case .abs: return "abs"
        case .quads: return "quads"
        case .hamstrings: return "hamstrings"
        case .glutes: return "glutes"
        case .calves: return "calves"
        }
    }
}
