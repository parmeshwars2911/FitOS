import Foundation

public enum CloudSyncContractError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
}

public struct CloudStateSnapshot: Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let generatedAt: Date
    public let sessions: [WorkoutSession]
    public let measurements: [BodyMeasurement]
    public let muscleTargets: [MuscleTarget]
    public let nutritionEntries: [NutritionEntry]
    public let nutritionTarget: NutritionTarget
    public let coachContext: CoachContext
    public let weeklyReview: WeeklyReview

    public init(
        schemaVersion: Int = CloudStateSnapshot.currentSchemaVersion,
        generatedAt: Date = Date(),
        sessions: [WorkoutSession],
        measurements: [BodyMeasurement],
        muscleTargets: [MuscleTarget],
        nutritionEntries: [NutritionEntry],
        nutritionTarget: NutritionTarget,
        coachContext: CoachContext,
        weeklyReview: WeeklyReview
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.sessions = sessions
        self.measurements = measurements
        self.muscleTargets = muscleTargets
        self.nutritionEntries = nutritionEntries
        self.nutritionTarget = nutritionTarget
        self.coachContext = coachContext
        self.weeklyReview = weeklyReview
    }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw CloudSyncContractError.unsupportedSchemaVersion(schemaVersion)
        }
    }
}

public struct RemoteCloudState: Codable, Sendable, Equatable {
    public let revision: Int64
    public let payload: CloudStateSnapshot
    public let updatedAt: Date

    public init(revision: Int64, payload: CloudStateSnapshot, updatedAt: Date) {
        self.revision = revision
        self.payload = payload
        self.updatedAt = updatedAt
    }
}
