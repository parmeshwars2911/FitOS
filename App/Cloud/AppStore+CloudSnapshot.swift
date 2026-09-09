import Foundation

@MainActor
extension AppStore {
    func makeCloudSnapshot(generatedAt: Date = Date()) -> CloudStateSnapshot {
        CloudStateSnapshot(
            generatedAt: generatedAt,
            sessions: sessions,
            measurements: measurements,
            muscleTargets: targets,
            nutritionEntries: nutritionEntries,
            nutritionTarget: nutritionTarget,
            coachContext: coachContext,
            weeklyReview: weeklyReview
        )
    }
}
