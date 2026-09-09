import XCTest
@testable import TrainingEngine

final class TrainingEngineTests: XCTestCase {
    private let bench = ExerciseDefinition(
        id: "bench_press",
        name: "Bench Press",
        muscles: [
            .init(.chest, factor: 1.0),
            .init(.triceps, factor: 0.45),
            .init(.frontDelts, factor: 0.4)
        ],
        equipment: "barbell",
        fatigueCost: 1.25
    )

    private let incline = ExerciseDefinition(
        id: "incline_press",
        name: "Incline Press",
        muscles: [
            .init(.chest, factor: 1.0),
            .init(.triceps, factor: 0.4),
            .init(.frontDelts, factor: 0.55)
        ],
        equipment: "dumbbell",
        fatigueCost: 1.1
    )

    private let shoulderPress = ExerciseDefinition(
        id: "shoulder_press",
        name: "Shoulder Press",
        muscles: [
            .init(.frontDelts, factor: 1.0),
            .init(.triceps, factor: 0.45),
            .init(.sideDelts, factor: 0.25)
        ],
        equipment: "dumbbell",
        fatigueCost: 1.0
    )

    private let lateralRaise = ExerciseDefinition(
        id: "lateral_raise",
        name: "Lateral Raise",
        muscles: [.init(.sideDelts, factor: 1.0)],
        equipment: "dumbbell",
        fatigueCost: 0.5
    )

    func testCompoundsGivePartialSecondaryMuscleCredit() throws {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        let workout = WorkoutSession(
            completedAt: now.addingTimeInterval(-72 * 3600),
            exercises: [
                CompletedExercise(
                    exercise: bench,
                    sets: Array(repeating: CompletedSet(reps: 8, loadKg: 60, rir: 2), count: 4)
                )
            ]
        )

        let targets = [
            MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 10),
            MuscleTarget(muscle: .triceps, effectiveSetsPer7Days: 10)
        ]

        let state = TrainingStateEngine().evaluate(sessions: [workout], targets: targets, asOf: now)
        let chest = try XCTUnwrap(state.state(for: .chest))
        let triceps = try XCTUnwrap(state.state(for: .triceps))

        XCTAssertEqual(chest.effectiveSets, 3.6, accuracy: 0.001)
        XCTAssertEqual(triceps.effectiveSets, 1.62, accuracy: 0.001)
        XCTAssertLessThan(triceps.effectiveSets, chest.effectiveSets)
    }

    func testMissedTricepsAbsAndTrapsBecomeNextWorkoutPriorities() throws {
        let now = Date(timeIntervalSince1970: 2_000_000_000)
        let pushDay = WorkoutSession(
            completedAt: now.addingTimeInterval(-24 * 3600),
            exercises: [
                CompletedExercise(exercise: bench, sets: hardSets(3)),
                CompletedExercise(exercise: incline, sets: hardSets(3)),
                CompletedExercise(exercise: shoulderPress, sets: hardSets(3)),
                CompletedExercise(exercise: lateralRaise, sets: hardSets(4))
            ]
        )

        let targets = [
            MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 8, fullRecoveryHours: 48),
            MuscleTarget(muscle: .frontDelts, effectiveSetsPer7Days: 6, fullRecoveryHours: 48),
            MuscleTarget(muscle: .sideDelts, effectiveSetsPer7Days: 8, fullRecoveryHours: 36),
            MuscleTarget(muscle: .triceps, effectiveSetsPer7Days: 10, fullRecoveryHours: 36),
            MuscleTarget(muscle: .back, effectiveSetsPer7Days: 12, fullRecoveryHours: 48),
            MuscleTarget(muscle: .biceps, effectiveSetsPer7Days: 8, fullRecoveryHours: 36),
            MuscleTarget(muscle: .abs, effectiveSetsPer7Days: 8, fullRecoveryHours: 24),
            MuscleTarget(muscle: .traps, effectiveSetsPer7Days: 6, fullRecoveryHours: 36)
        ]

        let state = TrainingStateEngine().evaluate(sessions: [pushDay], targets: targets, asOf: now)

        XCTAssertGreaterThan(try XCTUnwrap(state.state(for: .abs)).priorityScore,
                             try XCTUnwrap(state.state(for: .chest)).priorityScore)
        XCTAssertGreaterThan(try XCTUnwrap(state.state(for: .traps)).priorityScore,
                             try XCTUnwrap(state.state(for: .frontDelts)).priorityScore)

        let library: [ExerciseDefinition] = [
            .init(id: "lat_pulldown", name: "Lat Pulldown", muscles: [.init(.back, factor: 1), .init(.biceps, factor: 0.35)], equipment: "cable"),
            .init(id: "chest_supported_row", name: "Chest-Supported Row", muscles: [.init(.back, factor: 1), .init(.biceps, factor: 0.35), .init(.traps, factor: 0.3)], equipment: "machine"),
            .init(id: "triceps_pushdown", name: "Triceps Pushdown", muscles: [.init(.triceps, factor: 1)], equipment: "cable"),
            .init(id: "overhead_triceps", name: "Overhead Triceps Extension", muscles: [.init(.triceps, factor: 1)], equipment: "cable"),
            .init(id: "shrug", name: "Shrug", muscles: [.init(.traps, factor: 1)], equipment: "dumbbell"),
            .init(id: "cable_crunch", name: "Cable Crunch", muscles: [.init(.abs, factor: 1)], equipment: "cable"),
            .init(id: "curl", name: "Dumbbell Curl", muscles: [.init(.biceps, factor: 1)], equipment: "dumbbell"),
            bench
        ]

        let generated = WorkoutGenerator().generate(
            from: state,
            exerciseLibrary: library,
            constraints: WorkoutConstraint(durationMinutes: 55),
            maxExercises: 7
        )

        let exerciseIDs = Set(generated.exercises.map(\.exercise.id))
        XCTAssertTrue(exerciseIDs.contains("cable_crunch"))
        XCTAssertTrue(exerciseIDs.contains("shrug") || exerciseIDs.contains("chest_supported_row"))
        XCTAssertTrue(exerciseIDs.contains("triceps_pushdown") || exerciseIDs.contains("overhead_triceps"))
        XCTAssertFalse(exerciseIDs.contains("bench_press"), "Chest should not be prioritized immediately after a press-heavy day.")
    }

    private func hardSets(_ count: Int) -> [CompletedSet] {
        Array(repeating: CompletedSet(reps: 10, loadKg: 20, rir: 2), count: count)
    }
}
