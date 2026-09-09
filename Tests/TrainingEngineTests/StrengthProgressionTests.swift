import XCTest
@testable import TrainingEngine

final class StrengthProgressionTests: XCTestCase {
    private let bench = ExerciseDefinition(
        id: "bench_press",
        name: "Bench Press",
        muscles: [.init(.chest, factor: 1)],
        equipment: "barbell"
    )

    func testEstimated1RMUsesRepsAndOptionalRIR() throws {
        let engine = StrengthProgressionEngine()
        let noRIR = try XCTUnwrap(engine.estimated1RM(for: CompletedSet(reps: 5, loadKg: 100)))
        let withRIR = try XCTUnwrap(engine.estimated1RM(for: CompletedSet(reps: 5, loadKg: 100, rir: 2)))

        XCTAssertEqual(noRIR, 116.6667, accuracy: 0.001)
        XCTAssertEqual(withRIR, 123.3333, accuracy: 0.001)
        XCTAssertGreaterThan(withRIR, noRIR)
    }

    func testTopOfRangeRecommendsSmallLoadIncrease() {
        let previous = CompletedExercise(
            exercise: bench,
            sets: [
                CompletedSet(reps: 12, loadKg: 40, rir: 2),
                CompletedSet(reps: 12, loadKg: 40, rir: 1.5),
                CompletedSet(reps: 12, loadKg: 40, rir: 1)
            ]
        )

        let result = StrengthProgressionEngine().recommend(previous: previous, repRange: 8...12)
        XCTAssertEqual(result.action, .increaseLoad)
        XCTAssertEqual(result.suggestedLoadKg, 42.5)
    }

    func testInRangePerformanceKeepsLoadAndAddsReps() {
        let previous = CompletedExercise(
            exercise: bench,
            sets: [
                CompletedSet(reps: 10, loadKg: 40, rir: 2),
                CompletedSet(reps: 9, loadKg: 40, rir: 1.5),
                CompletedSet(reps: 8, loadKg: 40, rir: 1)
            ]
        )

        let result = StrengthProgressionEngine().recommend(previous: previous, repRange: 8...12)
        XCTAssertEqual(result.action, .addReps)
        XCTAssertEqual(result.suggestedLoadKg, 40)
    }

    func testTrendComparesLatestSessionWithPreviousSession() throws {
        let older = WorkoutSession(
            completedAt: Date(timeIntervalSince1970: 1_000),
            exercises: [CompletedExercise(exercise: bench, sets: [CompletedSet(reps: 8, loadKg: 40, rir: 1)])]
        )
        let newer = WorkoutSession(
            completedAt: Date(timeIntervalSince1970: 2_000),
            exercises: [CompletedExercise(exercise: bench, sets: [CompletedSet(reps: 10, loadKg: 42.5, rir: 1)])]
        )

        let trend = try XCTUnwrap(StrengthProgressionEngine().trend(for: bench.id, sessions: [newer, older]))
        XCTAssertGreaterThan(trend.latestEstimated1RMKg, try XCTUnwrap(trend.previousEstimated1RMKg))
        XCTAssertGreaterThan(try XCTUnwrap(trend.percentChangeFromPrevious), 0)
        XCTAssertEqual(trend.latestWorkingLoadKg, 42.5)
    }
}
