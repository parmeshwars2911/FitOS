import XCTest
@testable import TrainingEngine

final class ExercisePreferenceTests: XCTestCase {
    private let first = ExerciseDefinition(
        id: "first_chest",
        name: "First Chest",
        muscles: [.init(.chest, factor: 1.0)],
        equipment: "machine",
        fatigueCost: 1.0
    )

    private let preferred = ExerciseDefinition(
        id: "preferred_chest",
        name: "Preferred Chest",
        muscles: [.init(.chest, factor: 1.0)],
        equipment: "machine",
        fatigueCost: 1.0
    )

    func testPreferredExerciseWinsWhenProgrammingValueIsOtherwiseEqual() throws {
        let state = stateWithChestDebt()
        let generated = WorkoutGenerator().generate(
            from: state,
            exerciseLibrary: [first, preferred],
            exercisePreferences: [preferred.id: .prefer],
            maxExercises: 1
        )

        XCTAssertEqual(try XCTUnwrap(generated.exercises.first).exercise.id, preferred.id)
    }

    func testAvoidedExerciseIsNeverGenerated() throws {
        let state = stateWithChestDebt()
        let generated = WorkoutGenerator().generate(
            from: state,
            exerciseLibrary: [first, preferred],
            exercisePreferences: [first.id: .avoid],
            maxExercises: 1
        )

        XCTAssertEqual(try XCTUnwrap(generated.exercises.first).exercise.id, preferred.id)
        XCTAssertFalse(generated.exercises.contains { $0.exercise.id == first.id })
    }

    func testAvoidingEveryCandidateProducesNoExerciseInsteadOfIgnoringPreference() {
        let state = stateWithChestDebt()
        let generated = WorkoutGenerator().generate(
            from: state,
            exerciseLibrary: [first],
            exercisePreferences: [first.id: .avoid],
            maxExercises: 1
        )

        XCTAssertTrue(generated.exercises.isEmpty)
    }

    private func stateWithChestDebt() -> TrainingState {
        TrainingStateEngine().evaluate(
            sessions: [],
            targets: [MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 10, fullRecoveryHours: 48)],
            asOf: Date(timeIntervalSince1970: 2_000_000_000)
        )
    }
}
