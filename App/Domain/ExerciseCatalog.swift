import Foundation

enum ExerciseCatalog {
    static let all: [ExerciseDefinition] = [
        ExerciseDefinition(
            id: "barbell_bench_press",
            name: "Barbell Bench Press",
            muscles: [.init(.chest, factor: 1.0), .init(.triceps, factor: 0.45), .init(.frontDelts, factor: 0.35)],
            equipment: "barbell",
            fatigueCost: 1.15
        ),
        ExerciseDefinition(
            id: "incline_dumbbell_press",
            name: "Incline Dumbbell Press",
            muscles: [.init(.chest, factor: 0.9), .init(.frontDelts, factor: 0.5), .init(.triceps, factor: 0.35)],
            equipment: "dumbbell",
            fatigueCost: 1.0
        ),
        ExerciseDefinition(
            id: "lat_pulldown",
            name: "Lat Pulldown",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.45), .init(.rearDelts, factor: 0.2)],
            equipment: "cable"
        ),
        ExerciseDefinition(
            id: "chest_supported_row",
            name: "Chest-Supported Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.4), .init(.rearDelts, factor: 0.35), .init(.traps, factor: 0.25)],
            equipment: "machine"
        ),
        ExerciseDefinition(
            id: "shoulder_press",
            name: "Machine Shoulder Press",
            muscles: [.init(.frontDelts, factor: 1.0), .init(.triceps, factor: 0.4), .init(.sideDelts, factor: 0.25)],
            equipment: "machine",
            fatigueCost: 1.05
        ),
        ExerciseDefinition(
            id: "lateral_raise",
            name: "Cable Lateral Raise",
            muscles: [.init(.sideDelts, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.7
        ),
        ExerciseDefinition(
            id: "rear_delt_fly",
            name: "Rear Delt Fly",
            muscles: [.init(.rearDelts, factor: 1.0), .init(.traps, factor: 0.2)],
            equipment: "machine",
            fatigueCost: 0.7
        ),
        ExerciseDefinition(
            id: "triceps_pushdown",
            name: "Cable Triceps Pushdown",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.65
        ),
        ExerciseDefinition(
            id: "overhead_triceps_extension",
            name: "Overhead Triceps Extension",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.7
        ),
        ExerciseDefinition(
            id: "dumbbell_curl",
            name: "Dumbbell Curl",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        ExerciseDefinition(
            id: "back_squat",
            name: "Back Squat",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.7), .init(.hamstrings, factor: 0.2)],
            equipment: "barbell",
            fatigueCost: 1.35
        ),
        ExerciseDefinition(
            id: "leg_press",
            name: "Leg Press",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.55)],
            equipment: "machine",
            fatigueCost: 1.1
        ),
        ExerciseDefinition(
            id: "romanian_deadlift",
            name: "Romanian Deadlift",
            muscles: [.init(.hamstrings, factor: 1.0), .init(.glutes, factor: 0.75), .init(.back, factor: 0.15)],
            equipment: "barbell",
            fatigueCost: 1.25
        ),
        ExerciseDefinition(
            id: "leg_curl",
            name: "Seated Leg Curl",
            muscles: [.init(.hamstrings, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.75
        ),
        ExerciseDefinition(
            id: "standing_calf_raise",
            name: "Standing Calf Raise",
            muscles: [.init(.calves, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.6
        ),
        ExerciseDefinition(
            id: "cable_crunch",
            name: "Cable Crunch",
            muscles: [.init(.abs, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.55
        ),
        ExerciseDefinition(
            id: "dumbbell_shrug",
            name: "Dumbbell Shrug",
            muscles: [.init(.traps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        )
    ]
}
