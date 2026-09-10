import Foundation

struct SetDraft: Identifiable, Codable {
    let id: UUID
    var reps: Int
    var loadKg: Double
    var rir: Double
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        reps: Int = 10,
        loadKg: Double = 0,
        rir: Double = 2,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.reps = reps
        self.loadKg = loadKg
        self.rir = rir
        self.isCompleted = isCompleted
    }
}

struct ExerciseDraft: Identifiable, Codable {
    let id: UUID
    var exercise: ExerciseDefinition
    let plannedExerciseID: String?
    var sets: [SetDraft]

    init(
        id: UUID = UUID(),
        exercise: ExerciseDefinition,
        plannedExerciseID: String? = nil,
        setCount: Int = 3,
        defaultReps: Int = 10,
        defaultLoadKg: Double = 0
    ) {
        self.id = id
        self.exercise = exercise
        self.plannedExerciseID = plannedExerciseID
        self.sets = (0..<max(1, setCount)).map { _ in
            SetDraft(reps: defaultReps, loadKg: max(0, defaultLoadKg))
        }
    }
}

struct ActiveWorkoutDraft: Codable {
    static let currentSchemaVersion = 1

    let schemaVersion: Int
    let startedAt: Date
    let updatedAt: Date
    let plannedExerciseIDs: [String]
    let exercises: [ExerciseDraft]

    init(
        schemaVersion: Int = ActiveWorkoutDraft.currentSchemaVersion,
        startedAt: Date,
        updatedAt: Date = Date(),
        plannedExerciseIDs: [String],
        exercises: [ExerciseDraft]
    ) {
        self.schemaVersion = schemaVersion
        self.startedAt = startedAt
        self.updatedAt = updatedAt
        self.plannedExerciseIDs = plannedExerciseIDs
        self.exercises = exercises
    }

    var isSupported: Bool {
        schemaVersion == Self.currentSchemaVersion
    }

    var completedSetCount: Int {
        exercises.reduce(0) { partial, exercise in
            partial + exercise.sets.filter { $0.isCompleted && $0.reps > 0 }.count
        }
    }
}
