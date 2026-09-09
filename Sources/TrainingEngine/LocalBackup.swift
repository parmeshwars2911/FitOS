import Foundation

public enum FitOSBackupError: Error, Equatable, Sendable {
    case unsupportedSchemaVersion(Int)
}

public struct FitOSBackupArchive: Codable, Sendable, Equatable {
    public static let currentSchemaVersion = 1

    public let schemaVersion: Int
    public let generatedAt: Date
    public let sessions: [WorkoutSession]
    public let measurements: [BodyMeasurement]
    public let muscleTargets: [MuscleTarget]
    public let nutritionEntries: [NutritionEntry]
    public let nutritionTarget: NutritionTarget
    public let planAdherenceRecords: [WorkoutPlanAdherence]
    public let exercisePreferences: [String: ExercisePreference]
    public let workoutFeedbackRecords: [WorkoutRecommendationFeedback]

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        generatedAt: Date = Date(),
        sessions: [WorkoutSession],
        measurements: [BodyMeasurement],
        muscleTargets: [MuscleTarget],
        nutritionEntries: [NutritionEntry],
        nutritionTarget: NutritionTarget,
        planAdherenceRecords: [WorkoutPlanAdherence],
        exercisePreferences: [String: ExercisePreference],
        workoutFeedbackRecords: [WorkoutRecommendationFeedback]
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.sessions = sessions
        self.measurements = measurements
        self.muscleTargets = muscleTargets
        self.nutritionEntries = nutritionEntries
        self.nutritionTarget = nutritionTarget
        self.planAdherenceRecords = planAdherenceRecords
        self.exercisePreferences = exercisePreferences
        self.workoutFeedbackRecords = workoutFeedbackRecords
    }

    public func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw FitOSBackupError.unsupportedSchemaVersion(schemaVersion)
        }
    }
}
