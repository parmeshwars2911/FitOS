import XCTest
@testable import TrainingEngine

final class EquipmentConstraintTests: XCTestCase {
    func testGeneratorNeverSelectsEquipmentOutsideConstraint() {
        let state = TrainingState(
            asOf: Date(timeIntervalSince1970: 2_000_000_000),
            muscles: [
                MuscleState(
                    muscle: .chest,
                    effectiveSets: 0,
                    targetSets: 10,
                    deficitSets: 10,
                    recovery: 1,
                    priorityScore: 1,
                    lastStimulatedAt: nil
                )
            ]
        )
        let library = [
            ExerciseDefinition(id: "bench", name: "Bench", muscles: [.init(.chest, factor: 1)], equipment: "barbell"),
            ExerciseDefinition(id: "db_press", name: "Dumbbell Press", muscles: [.init(.chest, factor: 1)], equipment: "dumbbell")
        ]

        let workout = WorkoutGenerator().generate(
            from: state,
            exerciseLibrary: library,
            constraints: WorkoutConstraint(durationMinutes: 45, availableEquipment: ["dumbbell"])
        )

        XCTAssertFalse(workout.exercises.isEmpty)
        XCTAssertTrue(workout.exercises.allSatisfy { $0.exercise.equipment == "dumbbell" })
        XCTAssertFalse(workout.exercises.contains { $0.exercise.id == "bench" })
    }
}
