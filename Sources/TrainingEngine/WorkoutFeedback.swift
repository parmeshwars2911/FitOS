import Foundation

public enum WorkoutFeedbackReason: String, CaseIterable, Codable, Sendable, Equatable {
    case goodBalance
    case wrongExercises
    case tooLong
    case tooShort
    case tooHard
    case tooEasy
}

public struct WorkoutRecommendationFeedback: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let workoutSessionID: UUID
    public let rating: Int
    public let reason: WorkoutFeedbackReason?
    public let recordedAt: Date

    public init(
        id: UUID = UUID(),
        workoutSessionID: UUID,
        rating: Int,
        reason: WorkoutFeedbackReason? = nil,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.workoutSessionID = workoutSessionID
        self.rating = min(5, max(1, rating))
        self.reason = reason
        self.recordedAt = recordedAt
    }
}

public struct WorkoutFeedbackSummary: Sendable, Equatable {
    public let ratingCount: Int
    public let averageRating: Double?
    public let favorableCount: Int
    public let favorableRate: Double?

    public init(ratingCount: Int, averageRating: Double?, favorableCount: Int, favorableRate: Double?) {
        self.ratingCount = ratingCount
        self.averageRating = averageRating
        self.favorableCount = favorableCount
        self.favorableRate = favorableRate
    }
}

public struct WorkoutFeedbackEngine: Sendable {
    public init() {}

    public func summary(_ records: [WorkoutRecommendationFeedback]) -> WorkoutFeedbackSummary {
        guard !records.isEmpty else {
            return WorkoutFeedbackSummary(ratingCount: 0, averageRating: nil, favorableCount: 0, favorableRate: nil)
        }

        let total = records.reduce(0) { $0 + $1.rating }
        let favorable = records.filter { $0.rating >= 4 }.count
        return WorkoutFeedbackSummary(
            ratingCount: records.count,
            averageRating: Double(total) / Double(records.count),
            favorableCount: favorable,
            favorableRate: Double(favorable) / Double(records.count)
        )
    }
}
