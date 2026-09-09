import Foundation

public enum ProgressionAction: String, Codable, Sendable, Equatable {
    case increaseLoad
    case addReps
    case holdLoad
    case noLoadData
}

public struct ProgressionRecommendation: Codable, Sendable, Equatable {
    public let suggestedLoadKg: Double?
    public let action: ProgressionAction
    public let rationale: String

    public init(suggestedLoadKg: Double?, action: ProgressionAction, rationale: String) {
        self.suggestedLoadKg = suggestedLoadKg
        self.action = action
        self.rationale = rationale
    }
}

public struct ExerciseStrengthTrend: Codable, Sendable, Equatable, Identifiable {
    public var id: String { exerciseID }

    public let exerciseID: String
    public let exerciseName: String
    public let latestEstimated1RMKg: Double
    public let previousEstimated1RMKg: Double?
    public let bestEstimated1RMKg: Double
    public let latestWorkingLoadKg: Double?
    public let latestRecordedAt: Date

    public init(
        exerciseID: String,
        exerciseName: String,
        latestEstimated1RMKg: Double,
        previousEstimated1RMKg: Double?,
        bestEstimated1RMKg: Double,
        latestWorkingLoadKg: Double?,
        latestRecordedAt: Date
    ) {
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.latestEstimated1RMKg = latestEstimated1RMKg
        self.previousEstimated1RMKg = previousEstimated1RMKg
        self.bestEstimated1RMKg = bestEstimated1RMKg
        self.latestWorkingLoadKg = latestWorkingLoadKg
        self.latestRecordedAt = latestRecordedAt
    }

    public var percentChangeFromPrevious: Double? {
        guard let previousEstimated1RMKg, previousEstimated1RMKg > 0 else { return nil }
        return ((latestEstimated1RMKg - previousEstimated1RMKg) / previousEstimated1RMKg) * 100
    }
}

public struct StrengthProgressionEngine: Sendable {
    public init() {}

    public func estimated1RM(for set: CompletedSet) -> Double? {
        guard set.loadKg > 0, set.reps > 0 else { return nil }
        let boundedRIR = max(0, min(set.rir ?? 0, 5))
        let effectiveReps = Double(set.reps) + boundedRIR
        return set.loadKg * (1 + effectiveReps / 30)
    }

    public func recommend(
        previous: CompletedExercise,
        repRange: ClosedRange<Int> = 8...12,
        loadIncrementKg: Double = 2.5
    ) -> ProgressionRecommendation {
        let usable = previous.sets.filter { $0.loadKg > 0 && $0.reps > 0 }
        guard !usable.isEmpty, loadIncrementKg > 0 else {
            return ProgressionRecommendation(
                suggestedLoadKg: nil,
                action: .noLoadData,
                rationale: "No reliable previous working load is available yet."
            )
        }

        let workingLoad = median(usable.map(\.loadKg))
        let tolerance = max(0.5, loadIncrementKg / 2)
        let workingSets = usable.filter { abs($0.loadKg - workingLoad) <= tolerance }
        let sets = workingSets.isEmpty ? usable : workingSets
        let allAtTop = sets.allSatisfy { $0.reps >= repRange.upperBound }
        let allInRange = sets.allSatisfy { $0.reps >= repRange.lowerBound }
        let rirValues = sets.compactMap(\.rir)
        let averageRIR = rirValues.isEmpty ? nil : rirValues.reduce(0, +) / Double(rirValues.count)
        let hasRoomToProgress = averageRIR.map { $0 >= 1.0 } ?? true

        if allAtTop && hasRoomToProgress {
            let nextLoad = roundedToIncrement(workingLoad + loadIncrementKg, increment: loadIncrementKg)
            return ProgressionRecommendation(
                suggestedLoadKg: nextLoad,
                action: .increaseLoad,
                rationale: "You reached the top of the rep range across the last working sets, so increase load modestly."
            )
        }

        if allInRange {
            return ProgressionRecommendation(
                suggestedLoadKg: roundedToIncrement(workingLoad, increment: loadIncrementKg),
                action: .addReps,
                rationale: "Keep the same working load and try to add reps before increasing weight."
            )
        }

        return ProgressionRecommendation(
            suggestedLoadKg: roundedToIncrement(workingLoad, increment: loadIncrementKg),
            action: .holdLoad,
            rationale: "Keep the previous working load and stabilize the lower end of the rep range before progressing."
        )
    }

    public func trend(for exerciseID: String, sessions: [WorkoutSession]) -> ExerciseStrengthTrend? {
        struct Observation {
            let date: Date
            let exercise: CompletedExercise
            let estimated1RM: Double
            let workingLoad: Double?
        }

        let observations: [Observation] = sessions
            .sorted { $0.completedAt < $1.completedAt }
            .compactMap { session in
                guard let exercise = session.exercises.first(where: { $0.exercise.id == exerciseID }) else {
                    return nil
                }
                let estimates = exercise.sets.compactMap(estimated1RM)
                guard let best = estimates.max() else { return nil }
                let loads = exercise.sets.filter { $0.loadKg > 0 }.map(\.loadKg)
                return Observation(
                    date: session.completedAt,
                    exercise: exercise,
                    estimated1RM: best,
                    workingLoad: loads.isEmpty ? nil : median(loads)
                )
            }

        guard let latest = observations.last else { return nil }
        let previous = observations.dropLast().last
        let best = observations.map(\.estimated1RM).max() ?? latest.estimated1RM

        return ExerciseStrengthTrend(
            exerciseID: exerciseID,
            exerciseName: latest.exercise.exercise.name,
            latestEstimated1RMKg: latest.estimated1RM,
            previousEstimated1RMKg: previous?.estimated1RM,
            bestEstimated1RMKg: best,
            latestWorkingLoadKg: latest.workingLoad,
            latestRecordedAt: latest.date
        )
    }

    private func median(_ values: [Double]) -> Double {
        let sorted = values.sorted()
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    private func roundedToIncrement(_ value: Double, increment: Double) -> Double {
        (value / increment).rounded() * increment
    }
}
