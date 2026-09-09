import XCTest
@testable import TrainingEngine

final class ExerciseCatalogTests: XCTestCase {
    func testCatalogHasUniqueStableIDsAndUsefulBreadth() {
        let exercises = StandardExerciseCatalog.all
        let ids = exercises.map(\.id)

        XCTAssertGreaterThanOrEqual(exercises.count, 55)
        XCTAssertEqual(Set(ids).count, ids.count, "Exercise IDs must be globally unique because history and progression depend on them.")

        let legacyIDs: Set<String> = [
            "barbell_bench_press", "incline_dumbbell_press", "lat_pulldown", "chest_supported_row",
            "shoulder_press", "lateral_raise", "rear_delt_fly", "triceps_pushdown",
            "overhead_triceps_extension", "dumbbell_curl", "back_squat", "leg_press",
            "romanian_deadlift", "leg_curl", "standing_calf_raise", "cable_crunch", "dumbbell_shrug"
        ]
        XCTAssertTrue(legacyIDs.isSubset(of: Set(ids)), "Existing IDs must remain stable so old workout history still resolves correctly.")
    }

    func testEveryMuscleHasAtLeastTwoDirectOptions() {
        for muscle in MuscleGroup.allCases {
            let direct = StandardExerciseCatalog.all.filter { exercise in
                exercise.muscles.contains { $0.muscle == muscle && $0.factor >= 0.75 }
            }
            XCTAssertGreaterThanOrEqual(
                direct.count,
                2,
                "\(muscle.rawValue) needs at least two direct options so Train Today can substitute around equipment/preferences."
            )
        }
    }

    func testAllSupportedEquipmentClassesAreRepresented() {
        let equipment = Set(StandardExerciseCatalog.all.map(\.equipment))
        XCTAssertTrue(["barbell", "dumbbell", "cable", "machine", "bodyweight"].allSatisfy(equipment.contains))
    }

    func testContributionFactorsAndFatigueCostsStayWithinProgrammingBounds() {
        for exercise in StandardExerciseCatalog.all {
            XCTAssertGreaterThan(exercise.fatigueCost, 0)
            XCTAssertFalse(exercise.muscles.isEmpty)
            for contribution in exercise.muscles {
                XCTAssertGreaterThan(contribution.factor, 0)
                XCTAssertLessThanOrEqual(contribution.factor, 1.0)
            }
        }
    }
}
