import XCTest
@testable import TrainingEngine

final class LocalBackupTests: XCTestCase {
    func testArchiveRoundTripsAllBetaMetadata() throws {
        let sessionID = UUID()
        let session = WorkoutSession(id: sessionID, completedAt: Date(timeIntervalSince1970: 1000), exercises: [])
        let adherence = WorkoutPlanAdherence(
            workoutSessionID: sessionID,
            recordedAt: Date(timeIntervalSince1970: 1001),
            plannedExerciseIDs: ["bench"],
            completedExerciseIDs: ["bench"],
            acceptedPlannedExerciseIDs: ["bench"],
            replacedPlannedExerciseIDs: [],
            skippedPlannedExerciseIDs: []
        )
        let feedback = WorkoutRecommendationFeedback(
            workoutSessionID: sessionID,
            rating: 5,
            reason: .goodBalance,
            recordedAt: Date(timeIntervalSince1970: 1002)
        )
        let archive = FitOSBackupArchive(
            generatedAt: Date(timeIntervalSince1970: 2000),
            sessions: [session],
            measurements: [],
            muscleTargets: [MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 10)],
            nutritionEntries: [],
            nutritionTarget: NutritionTarget(calories: 2200, proteinGrams: 120),
            planAdherenceRecords: [adherence],
            exercisePreferences: ["bench": .prefer],
            workoutFeedbackRecords: [feedback]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(archive)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(FitOSBackupArchive.self, from: data)

        XCTAssertEqual(decoded, archive)
        XCTAssertEqual(decoded.exercisePreferences["bench"], .prefer)
        XCTAssertEqual(decoded.workoutFeedbackRecords.first?.rating, 5)
    }

    func testUnknownArchiveVersionFailsClosed() {
        let archive = FitOSBackupArchive(
            schemaVersion: 999,
            sessions: [],
            measurements: [],
            muscleTargets: [],
            nutritionEntries: [],
            nutritionTarget: .unset,
            planAdherenceRecords: [],
            exercisePreferences: [:],
            workoutFeedbackRecords: []
        )

        XCTAssertThrowsError(try archive.validate()) { error in
            XCTAssertEqual(error as? FitOSBackupError, .unsupportedSchemaVersion(999))
        }
    }
}
