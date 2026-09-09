import Foundation

public struct WorkoutPlanOutcome: Codable, Sendable, Equatable {
    public let plannedExerciseID: String?
    public let completedExerciseID: String

    public init(plannedExerciseID: String?, completedExerciseID: String) {
        self.plannedExerciseID = plannedExerciseID
        self.completedExerciseID = completedExerciseID
    }
}

public struct WorkoutPlanAdherence: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let workoutSessionID: UUID
    public let recordedAt: Date
    public let plannedExerciseIDs: [String]
    public let completedExerciseIDs: [String]
    public let acceptedPlannedExerciseIDs: [String]
    public let replacedPlannedExerciseIDs: [String]
    public let skippedPlannedExerciseIDs: [String]

    public init(
        id: UUID = UUID(),
        workoutSessionID: UUID,
        recordedAt: Date,
        plannedExerciseIDs: [String],
        completedExerciseIDs: [String],
        acceptedPlannedExerciseIDs: [String],
        replacedPlannedExerciseIDs: [String],
        skippedPlannedExerciseIDs: [String]
    ) {
        self.id = id
        self.workoutSessionID = workoutSessionID
        self.recordedAt = recordedAt
        self.plannedExerciseIDs = plannedExerciseIDs
        self.completedExerciseIDs = completedExerciseIDs
        self.acceptedPlannedExerciseIDs = acceptedPlannedExerciseIDs
        self.replacedPlannedExerciseIDs = replacedPlannedExerciseIDs
        self.skippedPlannedExerciseIDs = skippedPlannedExerciseIDs
    }

    public var acceptanceRatio: Double? {
        guard !plannedExerciseIDs.isEmpty else { return nil }
        return Double(acceptedPlannedExerciseIDs.count) / Double(plannedExerciseIDs.count)
    }
}

public struct WorkoutPlanAdherenceEngine: Sendable {
    public init() {}

    public func evaluate(
        workoutSessionID: UUID,
        plannedExerciseIDs: [String],
        outcomes: [WorkoutPlanOutcome],
        recordedAt: Date = Date()
    ) -> WorkoutPlanAdherence {
        let plannedSet = Set(plannedExerciseIDs)
        var represented = Set<String>()
        var accepted = Set<String>()
        var replaced = Set<String>()

        for outcome in outcomes {
            guard let plannedID = outcome.plannedExerciseID, plannedSet.contains(plannedID) else {
                continue
            }
            represented.insert(plannedID)
            if plannedID == outcome.completedExerciseID {
                accepted.insert(plannedID)
            } else {
                replaced.insert(plannedID)
            }
        }

        let skipped = plannedSet.subtracting(represented)
        let orderedAccepted = plannedExerciseIDs.filter(accepted.contains)
        let orderedReplaced = plannedExerciseIDs.filter(replaced.contains)
        let orderedSkipped = plannedExerciseIDs.filter(skipped.contains)

        return WorkoutPlanAdherence(
            workoutSessionID: workoutSessionID,
            recordedAt: recordedAt,
            plannedExerciseIDs: plannedExerciseIDs,
            completedExerciseIDs: outcomes.map(\.completedExerciseID),
            acceptedPlannedExerciseIDs: orderedAccepted,
            replacedPlannedExerciseIDs: orderedReplaced,
            skippedPlannedExerciseIDs: orderedSkipped
        )
    }
}
