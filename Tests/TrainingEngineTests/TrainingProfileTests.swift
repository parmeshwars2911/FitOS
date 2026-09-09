import XCTest
@testable import TrainingEngine

final class TrainingProfileTests: XCTestCase {
    func testBeginnerPresetStartsBelowExperiencedVolume() throws {
        let base = [
            MuscleTarget(muscle: .chest, effectiveSetsPer7Days: 12),
            MuscleTarget(muscle: .back, effectiveSetsPer7Days: 14)
        ]
        let engine = TrainingProfileEngine()
        let beginner = engine.personalizedTargets(baseTargets: base, experience: .beginner)
        let experienced = engine.personalizedTargets(baseTargets: base, experience: .experienced)

        XCTAssertEqual(beginner[0].effectiveSetsPer7Days, 8)
        XCTAssertEqual(beginner[1].effectiveSetsPer7Days, 10)
        XCTAssertEqual(experienced[0].effectiveSetsPer7Days, 12)
        XCTAssertEqual(experienced[1].effectiveSetsPer7Days, 14)
    }

    func testFocusMuscleGetsPriorityBoostWithoutChangingRecovery() throws {
        let base = [MuscleTarget(muscle: .sideDelts, effectiveSetsPer7Days: 10, goalPriority: 1.1, fullRecoveryHours: 36)]
        let result = TrainingProfileEngine().personalizedTargets(
            baseTargets: base,
            experience: .experienced,
            focusMuscles: [.sideDelts]
        )
        let target = try XCTUnwrap(result.first)

        XCTAssertEqual(target.effectiveSetsPer7Days, 10)
        XCTAssertEqual(target.goalPriority, 1.375, accuracy: 0.0001)
        XCTAssertEqual(target.fullRecoveryHours, 36)
    }
}
