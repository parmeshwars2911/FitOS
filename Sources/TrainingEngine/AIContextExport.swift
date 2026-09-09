import Foundation

public struct AIContextExport: Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let generatedAt: Date
    public let coachContext: CoachContext
    public let weeklyReview: WeeklyReview

    public init(
        schemaVersion: Int = AIContextExport.currentSchemaVersion,
        generatedAt: Date = Date(),
        coachContext: CoachContext,
        weeklyReview: WeeklyReview
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.coachContext = coachContext
        self.weeklyReview = weeklyReview
    }
}
