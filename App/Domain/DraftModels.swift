import Foundation

struct SetDraft: Identifiable {
    let id = UUID()
    var reps: Int = 10
    var loadKg: Double = 0
    var rir: Double = 2
    var isCompleted = false
}

struct ExerciseDraft: Identifiable {
    let id = UUID()
    var exercise: ExerciseDefinition
    let plannedExerciseID: String?
    var sets: [SetDraft]

    init(
        exercise: ExerciseDefinition,
        plannedExerciseID: String? = nil,
        setCount: Int = 3,
        defaultReps: Int = 10
    ) {
        self.exercise = exercise
        self.plannedExerciseID = plannedExerciseID
        self.sets = (0..<max(1, setCount)).map { _ in
            SetDraft(reps: defaultReps)
        }
    }
}
