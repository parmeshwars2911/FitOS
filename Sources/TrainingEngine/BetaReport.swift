import Foundation

public struct BetaReport: Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let generatedAt: Date
    public let appVersion: String
    public let buildNumber: String
    public let completedWorkoutCount: Int
    public let generatedWorkoutCount: Int
    public let plannedExerciseCount: Int
    public let acceptedExerciseCount: Int
    public let replacedExerciseCount: Int
    public let skippedExerciseCount: Int
    public let exerciseAcceptanceRate: Double?
    public let ratedWorkoutCount: Int
    public let averageUsefulnessRating: Double?
    public let favorableWorkoutCount: Int
    public let favorableWorkoutRate: Double?
    public let feedbackReasonCounts: [String: Int]

    public init(
        schemaVersion: Int = BetaReport.currentSchemaVersion,
        generatedAt: Date = Date(),
        appVersion: String,
        buildNumber: String,
        completedWorkoutCount: Int,
        generatedWorkoutCount: Int,
        plannedExerciseCount: Int,
        acceptedExerciseCount: Int,
        replacedExerciseCount: Int,
        skippedExerciseCount: Int,
        exerciseAcceptanceRate: Double?,
        ratedWorkoutCount: Int,
        averageUsefulnessRating: Double?,
        favorableWorkoutCount: Int,
        favorableWorkoutRate: Double?,
        feedbackReasonCounts: [String: Int]
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.completedWorkoutCount = completedWorkoutCount
        self.generatedWorkoutCount = generatedWorkoutCount
        self.plannedExerciseCount = plannedExerciseCount
        self.acceptedExerciseCount = acceptedExerciseCount
        self.replacedExerciseCount = replacedExerciseCount
        self.skippedExerciseCount = skippedExerciseCount
        self.exerciseAcceptanceRate = exerciseAcceptanceRate
        self.ratedWorkoutCount = ratedWorkoutCount
        self.averageUsefulnessRating = averageUsefulnessRating
        self.favorableWorkoutCount = favorableWorkoutCount
        self.favorableWorkoutRate = favorableWorkoutRate
        self.feedbackReasonCounts = feedbackReasonCounts
    }
}

public struct BetaReportEngine: Sendable {
    public init() {}

    public func makeReport(
        completedWorkoutCount: Int,
        adherenceRecords: [WorkoutPlanAdherence],
        feedbackRecords: [WorkoutRecommendationFeedback],
        appVersion: String,
        buildNumber: String,
        generatedAt: Date = Date()
    ) -> BetaReport {
        let planned = adherenceRecords.reduce(0) { $0 + $1.plannedExerciseIDs.count }
        let accepted = adherenceRecords.reduce(0) { $0 + $1.acceptedPlannedExerciseIDs.count }
        let replaced = adherenceRecords.reduce(0) { $0 + $1.replacedPlannedExerciseIDs.count }
        let skipped = adherenceRecords.reduce(0) { $0 + $1.skippedPlannedExerciseIDs.count }
        let feedbackSummary = WorkoutFeedbackEngine().summary(feedbackRecords)

        var reasonCounts: [String: Int] = [:]
        for reason in feedbackRecords.compactMap(\.reason) {
            reasonCounts[reason.rawValue, default: 0] += 1
        }

        return BetaReport(
            generatedAt: generatedAt,
            appVersion: appVersion,
            buildNumber: buildNumber,
            completedWorkoutCount: max(0, completedWorkoutCount),
            generatedWorkoutCount: adherenceRecords.count,
            plannedExerciseCount: planned,
            acceptedExerciseCount: accepted,
            replacedExerciseCount: replaced,
            skippedExerciseCount: skipped,
            exerciseAcceptanceRate: planned > 0 ? Double(accepted) / Double(planned) : nil,
            ratedWorkoutCount: feedbackSummary.ratingCount,
            averageUsefulnessRating: feedbackSummary.averageRating,
            favorableWorkoutCount: feedbackSummary.favorableCount,
            favorableWorkoutRate: feedbackSummary.favorableRate,
            feedbackReasonCounts: reasonCounts
        )
    }

    public func encodeJSON(_ report: BetaReport) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(report) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
