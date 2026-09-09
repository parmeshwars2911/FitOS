import Foundation

public struct WorkoutGenerator: Sendable {
    public init() {}

    public func generate(
        from state: TrainingState,
        exerciseLibrary: [ExerciseDefinition],
        constraints: WorkoutConstraint = WorkoutConstraint(),
        exerciseHistory: [WorkoutSession] = [],
        exercisePreferences: [String: ExercisePreference] = [:],
        readiness: SessionReadiness = .normal,
        maxExercises: Int = 7
    ) -> GeneratedWorkout {
        let candidates = exerciseLibrary.filter { exercise in
            guard !constraints.excludedExercises.contains(exercise.id) else { return false }
            guard exercisePreferences[exercise.id] != .avoid else { return false }
            return constraints.availableEquipment.isEmpty || constraints.availableEquipment.contains(exercise.equipment)
        }

        var latestExerciseByID: [String: CompletedExercise] = [:]
        for session in exerciseHistory.sorted(by: { $0.completedAt > $1.completedAt }) {
            for exercise in session.exercises where latestExerciseByID[exercise.exercise.id] == nil {
                latestExerciseByID[exercise.exercise.id] = exercise
            }
        }
        let progressionEngine = StrengthProgressionEngine()

        let stateByMuscle = Dictionary(uniqueKeysWithValues: state.muscles.map { ($0.muscle, $0) })
        let ranked = candidates.map { exercise -> (ExerciseDefinition, Double, MuscleGroup?) in
            let contributions = exercise.muscles.map { contribution -> (Double, MuscleGroup) in
                let muscleState = stateByMuscle[contribution.muscle]
                let priority = muscleState?.priorityScore ?? 0
                let recovery = muscleState?.recovery ?? 1
                let score = priority * contribution.factor * (0.5 + 0.5 * recovery)
                return (score, contribution.muscle)
            }
            let best = contributions.max { $0.0 < $1.0 }
            let aggregate = contributions.reduce(0.0) { $0 + $1.0 }
            let preferenceMultiplier = exercisePreferences[exercise.id] == .prefer ? 1.15 : 1.0
            let fatigueAdjusted = (aggregate / max(0.5, exercise.fatigueCost)) * preferenceMultiplier
            return (exercise, fatigueAdjusted, best?.1)
        }
        .filter { $0.1 > 0.05 }
        .sorted { $0.1 > $1.1 }

        let estimatedMinutesPerSet = 3.0
        let warmupBufferMinutes = 8.0
        let availableSetMinutes = max(0, Double(constraints.durationMinutes) - warmupBufferMinutes)
        let normalSetBudget = max(1, Int(availableSetMinutes / estimatedMinutesPerSet))
        var remainingSets = max(1, Int(floor(Double(normalSetBudget) * readiness.setBudgetMultiplier)))
        var selected: [PlannedExercise] = []
        var directSetsByMuscle: [MuscleGroup: Int] = [:]
        var selectedExerciseIDs = Set<String>()

        func plannedExercise(_ exercise: ExerciseDefinition, for muscleState: MuscleState, muscle: MuscleGroup, sets: Int) -> PlannedExercise {
            let trainingReason: String
            if muscleState.deficitSets >= muscleState.targetSets * 0.6 {
                trainingReason = "High training debt: \(muscle.rawValue) is well below its rolling target."
            } else if muscleState.recovery >= 0.9 {
                trainingReason = "\(muscle.rawValue) is recovered and still below target."
            } else {
                trainingReason = "Adds useful volume to \(muscle.rawValue) while respecting recent fatigue."
            }

            let readinessInstruction: String
            switch readiness {
            case .low:
                readinessInstruction = " Low readiness today: keep about 3 RIR and reduce load if needed."
            case .normal:
                readinessInstruction = " Aim for about 2 RIR on working sets."
            case .high:
                readinessInstruction = " High readiness today: about 1–2 RIR is fine, without adding extra weekly volume."
            }

            let progression = latestExerciseByID[exercise.id].map {
                progressionEngine.recommend(previous: $0, repRange: 8...12)
            }

            return PlannedExercise(
                exercise: exercise,
                sets: sets,
                repRange: 8...12,
                reason: trainingReason + readinessInstruction,
                suggestedLoadKg: progression?.suggestedLoadKg,
                progressionNote: progression?.rationale
            )
        }

        let priorityMuscles = state.muscles
            .filter { $0.priorityScore >= 0.20 && $0.deficitSets >= 1.5 }
            .prefix(maxExercises)

        for muscleState in priorityMuscles {
            guard selected.count < maxExercises, remainingSets >= 2 else { break }

            let directCandidate = ranked.first { exercise, _, _ in
                !selectedExerciseIDs.contains(exercise.id) &&
                exercise.muscles.contains { $0.muscle == muscleState.muscle && $0.factor >= 0.75 }
            }

            guard let (exercise, _, _) = directCandidate else { continue }
            let normalDesired = Int(ceil(min(3, max(2, muscleState.deficitSets))))
            let desired = readiness == .low ? min(2, normalDesired) : normalDesired
            let sets = min(desired, remainingSets)
            guard sets >= 2 else { continue }

            selected.append(plannedExercise(exercise, for: muscleState, muscle: muscleState.muscle, sets: sets))
            selectedExerciseIDs.insert(exercise.id)
            directSetsByMuscle[muscleState.muscle, default: 0] += sets
            remainingSets -= sets
        }

        for (exercise, _, topMuscle) in ranked {
            guard selected.count < maxExercises, remainingSets >= 2 else { break }
            guard !selectedExerciseIDs.contains(exercise.id) else { continue }
            guard let topMuscle, let muscleState = stateByMuscle[topMuscle] else { continue }
            if directSetsByMuscle[topMuscle, default: 0] >= 6 { continue }

            let normalDesired = Int(ceil(min(4, max(2, muscleState.deficitSets))))
            let desired = readiness == .low ? min(2, normalDesired) : normalDesired
            let sets = min(desired, remainingSets)
            guard sets >= 2 else { continue }

            selected.append(plannedExercise(exercise, for: muscleState, muscle: topMuscle, sets: sets))
            selectedExerciseIDs.insert(exercise.id)
            directSetsByMuscle[topMuscle, default: 0] += sets
            remainingSets -= sets
        }

        let totalSets = selected.reduce(0) { $0 + $1.sets }
        let estimated = min(constraints.durationMinutes, Int(warmupBufferMinutes + Double(totalSets) * estimatedMinutesPerSet))

        var rationale: [String] = []
        switch readiness {
        case .low:
            rationale.append("Low readiness: FitOS reduced today's set budget by 25% and recommends ~3 RIR. Training debt remains for later sessions.")
        case .normal:
            rationale.append("Normal readiness: standard session volume with ~2 RIR guidance.")
        case .high:
            rationale.append("High readiness: keep the planned weekly volume; working sets can approach ~1–2 RIR without adding extra sets.")
        }

        rationale += state.muscles
            .filter { $0.priorityScore > 0.25 }
            .prefix(4)
            .map { muscle in
                let completed = String(format: "%.1f", muscle.effectiveSets)
                let target = String(format: "%.1f", muscle.targetSets)
                return "\(muscle.muscle.rawValue): \(completed)/\(target) effective sets, \(Int(muscle.recovery * 100))% recovered."
            }

        return GeneratedWorkout(
            generatedAt: state.asOf,
            estimatedMinutes: estimated,
            exercises: selected,
            rationale: rationale
        )
    }
}
