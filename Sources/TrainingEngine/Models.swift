import Foundation

public enum MuscleGroup: String, CaseIterable, Codable, Sendable {
    case chest, back, frontDelts, sideDelts, rearDelts
    case triceps, biceps, traps, abs
    case quads, hamstrings, glutes, calves
}

public struct MuscleContribution: Codable, Sendable, Equatable {
    public let muscle: MuscleGroup
    public let factor: Double

    public init(_ muscle: MuscleGroup, factor: Double) {
        self.muscle = muscle
        self.factor = factor
    }
}

public struct ExerciseDefinition: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let muscles: [MuscleContribution]
    public let equipment: String
    public let fatigueCost: Double

    public init(id: String, name: String, muscles: [MuscleContribution], equipment: String, fatigueCost: Double = 1.0) {
        self.id = id
        self.name = name
        self.muscles = muscles
        self.equipment = equipment
        self.fatigueCost = fatigueCost
    }
}

public struct CompletedSet: Codable, Sendable, Equatable {
    public let reps: Int
    public let loadKg: Double
    public let rir: Double?

    public init(reps: Int, loadKg: Double, rir: Double? = nil) {
        self.reps = reps
        self.loadKg = loadKg
        self.rir = rir
    }
}

public struct CompletedExercise: Codable, Sendable, Equatable {
    public let exercise: ExerciseDefinition
    public let sets: [CompletedSet]

    public init(exercise: ExerciseDefinition, sets: [CompletedSet]) {
        self.exercise = exercise
        self.sets = sets
    }
}

public struct WorkoutSession: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let completedAt: Date
    public let exercises: [CompletedExercise]

    public init(id: UUID = UUID(), completedAt: Date, exercises: [CompletedExercise]) {
        self.id = id
        self.completedAt = completedAt
        self.exercises = exercises
    }
}

public struct MuscleTarget: Codable, Sendable, Equatable {
    public let muscle: MuscleGroup
    public let effectiveSetsPer7Days: Double
    public let goalPriority: Double
    public let fullRecoveryHours: Double

    public init(muscle: MuscleGroup, effectiveSetsPer7Days: Double, goalPriority: Double = 1.0, fullRecoveryHours: Double = 48) {
        self.muscle = muscle
        self.effectiveSetsPer7Days = effectiveSetsPer7Days
        self.goalPriority = goalPriority
        self.fullRecoveryHours = fullRecoveryHours
    }
}

public struct MuscleState: Codable, Sendable, Equatable {
    public let muscle: MuscleGroup
    public let effectiveSets: Double
    public let targetSets: Double
    public let deficitSets: Double
    public let recovery: Double
    public let priorityScore: Double
    public let lastStimulatedAt: Date?

    public var completionRatio: Double {
        guard targetSets > 0 else { return 1 }
        return min(1, effectiveSets / targetSets)
    }
}

public struct TrainingState: Codable, Sendable, Equatable {
    public let asOf: Date
    public let muscles: [MuscleState]

    public func state(for muscle: MuscleGroup) -> MuscleState? {
        muscles.first { $0.muscle == muscle }
    }
}

public struct WorkoutConstraint: Codable, Sendable, Equatable {
    public let durationMinutes: Int
    public let availableEquipment: Set<String>
    public let excludedExercises: Set<String>

    public init(durationMinutes: Int = 60, availableEquipment: Set<String> = [], excludedExercises: Set<String> = []) {
        self.durationMinutes = durationMinutes
        self.availableEquipment = availableEquipment
        self.excludedExercises = excludedExercises
    }
}

public struct PlannedExercise: Codable, Sendable, Equatable {
    public let exercise: ExerciseDefinition
    public let sets: Int
    public let repRange: ClosedRange<Int>
    public let reason: String

    public init(exercise: ExerciseDefinition, sets: Int, repRange: ClosedRange<Int>, reason: String) {
        self.exercise = exercise
        self.sets = sets
        self.repRange = repRange
        self.reason = reason
    }
}

public struct GeneratedWorkout: Codable, Sendable, Equatable {
    public let generatedAt: Date
    public let estimatedMinutes: Int
    public let exercises: [PlannedExercise]
    public let rationale: [String]
}
