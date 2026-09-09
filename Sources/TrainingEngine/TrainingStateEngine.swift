import Foundation

public struct TrainingStateEngine: Sendable {
    public let rollingWindowDays: Double

    public init(rollingWindowDays: Double = 7) {
        self.rollingWindowDays = rollingWindowDays
    }

    public func evaluate(
        sessions: [WorkoutSession],
        targets: [MuscleTarget],
        asOf: Date = Date()
    ) -> TrainingState {
        let windowStart = asOf.addingTimeInterval(-rollingWindowDays * 24 * 3600)
        let recent = sessions.filter { $0.completedAt >= windowStart && $0.completedAt <= asOf }

        let states = targets.map { target -> MuscleState in
            var effectiveSets = 0.0
            var lastStimulatedAt: Date?

            for session in recent {
                for performed in session.exercises {
                    guard let contribution = performed.exercise.muscles.first(where: { $0.muscle == target.muscle }) else {
                        continue
                    }

                    let setStimulus = performed.sets.reduce(0.0) { partial, set in
                        partial + effortFactor(rir: set.rir)
                    }
                    effectiveSets += setStimulus * contribution.factor

                    if contribution.factor > 0.1 {
                        if lastStimulatedAt == nil || session.completedAt > lastStimulatedAt! {
                            lastStimulatedAt = session.completedAt
                        }
                    }
                }
            }

            let deficit = max(0, target.effectiveSetsPer7Days - effectiveSets)
            let recovery = recoveryScore(
                lastStimulatedAt: lastStimulatedAt,
                fullRecoveryHours: target.fullRecoveryHours,
                asOf: asOf
            )

            let deficitRatio: Double
            if target.effectiveSetsPer7Days > 0 {
                deficitRatio = min(1, deficit / target.effectiveSetsPer7Days)
            } else {
                deficitRatio = 0
            }

            let recoveryMultiplier = 0.2 + (0.8 * recovery)
            let priority = deficitRatio * recoveryMultiplier * max(0.1, target.goalPriority)

            return MuscleState(
                muscle: target.muscle,
                effectiveSets: effectiveSets,
                targetSets: target.effectiveSetsPer7Days,
                deficitSets: deficit,
                recovery: recovery,
                priorityScore: priority,
                lastStimulatedAt: lastStimulatedAt
            )
        }

        return TrainingState(
            asOf: asOf,
            muscles: states.sorted { $0.priorityScore > $1.priorityScore }
        )
    }

    private func effortFactor(rir: Double?) -> Double {
        guard let rir else { return 0.85 }
        switch rir {
        case ...1: return 1.0
        case ...3: return 0.9
        case ...5: return 0.7
        default: return 0.5
        }
    }

    private func recoveryScore(lastStimulatedAt: Date?, fullRecoveryHours: Double, asOf: Date) -> Double {
        guard let lastStimulatedAt else { return 1.0 }
        let elapsedHours = max(0, asOf.timeIntervalSince(lastStimulatedAt) / 3600)
        let meaningfulRecoveryStarts = 12.0
        guard fullRecoveryHours > meaningfulRecoveryStarts else { return 1.0 }
        return min(1, max(0, (elapsedHours - meaningfulRecoveryStarts) / (fullRecoveryHours - meaningfulRecoveryStarts)))
    }
}
