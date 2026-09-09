import Foundation

public enum TrainingExperience: String, CaseIterable, Codable, Sendable, Equatable {
    case beginner
    case intermediate
    case experienced
}

public struct TrainingProfileEngine: Sendable {
    public init() {}

    public func personalizedTargets(
        baseTargets: [MuscleTarget],
        experience: TrainingExperience,
        focusMuscles: [MuscleGroup] = []
    ) -> [MuscleTarget] {
        let volumeMultiplier: Double
        switch experience {
        case .beginner: volumeMultiplier = 0.70
        case .intermediate: volumeMultiplier = 0.85
        case .experienced: volumeMultiplier = 1.00
        }

        return baseTargets.map { target in
            let scaledSets: Double
            if target.effectiveSetsPer7Days <= 0 {
                scaledSets = 0
            } else {
                scaledSets = max(4, (target.effectiveSetsPer7Days * volumeMultiplier).rounded())
            }
            let focusBoost = focusMuscles.contains(target.muscle) ? 1.25 : 1.0

            return MuscleTarget(
                muscle: target.muscle,
                effectiveSetsPer7Days: scaledSets,
                goalPriority: target.goalPriority * focusBoost,
                fullRecoveryHours: target.fullRecoveryHours
            )
        }
    }
}
