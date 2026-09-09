import Foundation

extension AppStore {
    var workoutFeedbackRecords: [WorkoutRecommendationFeedback] {
        let activeSessionIDs = Set(sessions.map(\.id))
        return WorkoutFeedbackPersistence().load()
            .filter { activeSessionIDs.contains($0.workoutSessionID) }
            .sorted { $0.recordedAt > $1.recordedAt }
    }

    var workoutFeedbackSummary: WorkoutFeedbackSummary {
        WorkoutFeedbackEngine().summary(workoutFeedbackRecords)
    }

    var pendingWorkoutFeedbackSessionID: UUID? {
        let rated = Set(workoutFeedbackRecords.map(\.workoutSessionID))
        return planAdherenceRecords
            .sorted { $0.recordedAt > $1.recordedAt }
            .first { !rated.contains($0.workoutSessionID) }?
            .workoutSessionID
    }

    func recordWorkoutFeedback(
        sessionID: UUID,
        rating: Int,
        reason: WorkoutFeedbackReason? = nil
    ) {
        let persistence = WorkoutFeedbackPersistence()
        var records = persistence.load()
        records.removeAll { $0.workoutSessionID == sessionID }
        records.append(
            WorkoutRecommendationFeedback(
                workoutSessionID: sessionID,
                rating: rating,
                reason: reason
            )
        )
        persistence.save(records)
        objectWillChange.send()
    }
}
