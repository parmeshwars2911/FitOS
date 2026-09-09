import XCTest
@testable import TrainingEngine

final class SessionReadinessTests: XCTestCase {
    private let library = [
        ExerciseDefinition(id: "row", name: "Row", muscles: [.init(.back, factor: 1)], equipment: "machine"),
        ExerciseDefinition(id: "pulldown", name: "Pulldown", muscles: [.init(.back, factor: 1)], equipment: "cable"),
        ExerciseDefinition(id: "curl", name: "Curl", muscles: [.init(.biceps, factor: 1)], equipment: "dumbbell"),
        ExerciseDefinition(id: "crunch", name: "Crunch", muscles: [.init(.abs, factor: 1)], equipment: "cable")
    ]

    private var state: TrainingState {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        return TrainingState(
            asOf: now,
            muscles: [
                MuscleState(muscle: .back, effectiveSets: 0, targetSets: 12, deficitSets: 12, recovery: 1, priorityScore: 1, lastStimulatedAt: nil),
                MuscleState(muscle: .biceps, effectiveSets: 0, targetSets: 8, deficitSets: 8, recovery: 1, priorityScore: 1, lastStimulatedAt: nil),
                MuscleState(muscle: .abs, effectiveSets: 0, targetSets: 8, deficitSets: 8, recovery: 1, priorityScore: 1, lastStimulatedAt: nil)
            ]
        )
    }

    func testLowReadinessReducesSetBudget() {
        let generator = WorkoutGenerator()
        let normal = generator.generate(from: state, exerciseLibrary: library, constraints: WorkoutConstraint(durationMinutes: 60), readiness: .normal)
        let low = generator.generate(from: state, exerciseLibrary: library, constraints: WorkoutConstraint(durationMinutes: 60), readiness: .low)

        XCTAssertLessThan(low.exercises.reduce(0) { $0 + $1.sets }, normal.exercises.reduce(0) { $0 + $1.sets })
        XCTAssertTrue(low.rationale.contains { $0.contains("Low readiness") })
    }

    func testHighReadinessDoesNotIncreaseSetBudgetAboveNormal() {
        let generator = WorkoutGenerator()
        let normal = generator.generate(from: state, exerciseLibrary: library, constraints: WorkoutConstraint(durationMinutes: 60), readiness: .normal)
        let high = generator.generate(from: state, exerciseLibrary: library, constraints: WorkoutConstraint(durationMinutes: 60), readiness: .high)

        XCTAssertEqual(high.exercises.reduce(0) { $0 + $1.sets }, normal.exercises.reduce(0) { $0 + $1.sets })
        XCTAssertTrue(high.rationale.contains { $0.contains("High readiness") })
    }
}
