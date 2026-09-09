import Foundation

/// Canonical FitOS exercise definitions used by the iOS app and future API/MCP surfaces.
/// Muscle contribution factors are programming heuristics for workload accounting, not physiological measurements.
public enum StandardExerciseCatalog {
    public static let all: [ExerciseDefinition] = [
        // MARK: Chest / pressing
        .init(
            id: "barbell_bench_press",
            name: "Barbell Bench Press",
            muscles: [.init(.chest, factor: 1.0), .init(.triceps, factor: 0.45), .init(.frontDelts, factor: 0.35)],
            equipment: "barbell",
            fatigueCost: 1.15
        ),
        .init(
            id: "dumbbell_bench_press",
            name: "Dumbbell Bench Press",
            muscles: [.init(.chest, factor: 1.0), .init(.triceps, factor: 0.35), .init(.frontDelts, factor: 0.30)],
            equipment: "dumbbell",
            fatigueCost: 1.05
        ),
        .init(
            id: "incline_dumbbell_press",
            name: "Incline Dumbbell Press",
            muscles: [.init(.chest, factor: 0.9), .init(.frontDelts, factor: 0.5), .init(.triceps, factor: 0.35)],
            equipment: "dumbbell",
            fatigueCost: 1.0
        ),
        .init(
            id: "incline_barbell_press",
            name: "Incline Barbell Press",
            muscles: [.init(.chest, factor: 0.9), .init(.frontDelts, factor: 0.5), .init(.triceps, factor: 0.40)],
            equipment: "barbell",
            fatigueCost: 1.10
        ),
        .init(
            id: "machine_chest_press",
            name: "Machine Chest Press",
            muscles: [.init(.chest, factor: 1.0), .init(.triceps, factor: 0.35), .init(.frontDelts, factor: 0.25)],
            equipment: "machine",
            fatigueCost: 0.90
        ),
        .init(
            id: "cable_fly",
            name: "Cable Fly",
            muscles: [.init(.chest, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.65
        ),
        .init(
            id: "pec_deck",
            name: "Pec Deck",
            muscles: [.init(.chest, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.65
        ),
        .init(
            id: "push_up",
            name: "Push-Up",
            muscles: [.init(.chest, factor: 0.9), .init(.triceps, factor: 0.35), .init(.frontDelts, factor: 0.25)],
            equipment: "bodyweight",
            fatigueCost: 0.75
        ),
        .init(
            id: "chest_dip",
            name: "Chest-Focused Dip",
            muscles: [.init(.chest, factor: 1.0), .init(.triceps, factor: 0.5), .init(.frontDelts, factor: 0.25)],
            equipment: "bodyweight",
            fatigueCost: 1.00
        ),

        // MARK: Back
        .init(
            id: "lat_pulldown",
            name: "Lat Pulldown",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.45), .init(.rearDelts, factor: 0.2)],
            equipment: "cable"
        ),
        .init(
            id: "pull_up",
            name: "Pull-Up",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.45), .init(.rearDelts, factor: 0.15)],
            equipment: "bodyweight",
            fatigueCost: 1.10
        ),
        .init(
            id: "assisted_pull_up",
            name: "Assisted Pull-Up",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.45)],
            equipment: "machine",
            fatigueCost: 0.90
        ),
        .init(
            id: "seated_cable_row",
            name: "Seated Cable Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.4), .init(.rearDelts, factor: 0.3), .init(.traps, factor: 0.25)],
            equipment: "cable",
            fatigueCost: 0.90
        ),
        .init(
            id: "one_arm_dumbbell_row",
            name: "One-Arm Dumbbell Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.4), .init(.rearDelts, factor: 0.25), .init(.traps, factor: 0.2)],
            equipment: "dumbbell",
            fatigueCost: 0.95
        ),
        .init(
            id: "barbell_row",
            name: "Barbell Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.4), .init(.rearDelts, factor: 0.3), .init(.traps, factor: 0.3)],
            equipment: "barbell",
            fatigueCost: 1.20
        ),
        .init(
            id: "chest_supported_row",
            name: "Chest-Supported Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.4), .init(.rearDelts, factor: 0.35), .init(.traps, factor: 0.25)],
            equipment: "machine"
        ),
        .init(
            id: "machine_high_row",
            name: "Machine High Row",
            muscles: [.init(.back, factor: 1.0), .init(.biceps, factor: 0.35), .init(.rearDelts, factor: 0.4), .init(.traps, factor: 0.3)],
            equipment: "machine",
            fatigueCost: 0.90
        ),
        .init(
            id: "straight_arm_pulldown",
            name: "Straight-Arm Pulldown",
            muscles: [.init(.back, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.65
        ),

        // MARK: Shoulders
        .init(
            id: "shoulder_press",
            name: "Machine Shoulder Press",
            muscles: [.init(.frontDelts, factor: 1.0), .init(.triceps, factor: 0.4), .init(.sideDelts, factor: 0.25)],
            equipment: "machine",
            fatigueCost: 1.05
        ),
        .init(
            id: "dumbbell_shoulder_press",
            name: "Dumbbell Shoulder Press",
            muscles: [.init(.frontDelts, factor: 1.0), .init(.triceps, factor: 0.4), .init(.sideDelts, factor: 0.3)],
            equipment: "dumbbell",
            fatigueCost: 1.05
        ),
        .init(
            id: "barbell_overhead_press",
            name: "Barbell Overhead Press",
            muscles: [.init(.frontDelts, factor: 1.0), .init(.triceps, factor: 0.4), .init(.sideDelts, factor: 0.25)],
            equipment: "barbell",
            fatigueCost: 1.15
        ),
        .init(
            id: "lateral_raise",
            name: "Cable Lateral Raise",
            muscles: [.init(.sideDelts, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.7
        ),
        .init(
            id: "dumbbell_lateral_raise",
            name: "Dumbbell Lateral Raise",
            muscles: [.init(.sideDelts, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        .init(
            id: "machine_lateral_raise",
            name: "Machine Lateral Raise",
            muscles: [.init(.sideDelts, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.60
        ),
        .init(
            id: "rear_delt_fly",
            name: "Rear Delt Fly",
            muscles: [.init(.rearDelts, factor: 1.0), .init(.traps, factor: 0.2)],
            equipment: "machine",
            fatigueCost: 0.7
        ),
        .init(
            id: "cable_rear_delt_fly",
            name: "Cable Rear Delt Fly",
            muscles: [.init(.rearDelts, factor: 1.0), .init(.traps, factor: 0.15)],
            equipment: "cable",
            fatigueCost: 0.65
        ),
        .init(
            id: "face_pull",
            name: "Face Pull",
            muscles: [.init(.rearDelts, factor: 0.85), .init(.traps, factor: 0.4)],
            equipment: "cable",
            fatigueCost: 0.65
        ),

        // MARK: Triceps
        .init(
            id: "triceps_pushdown",
            name: "Cable Triceps Pushdown",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.65
        ),
        .init(
            id: "overhead_triceps_extension",
            name: "Overhead Triceps Extension",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.7
        ),
        .init(
            id: "dumbbell_overhead_triceps_extension",
            name: "Dumbbell Overhead Triceps Extension",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.70
        ),
        .init(
            id: "lying_triceps_extension",
            name: "Lying Triceps Extension",
            muscles: [.init(.triceps, factor: 1.0)],
            equipment: "barbell",
            fatigueCost: 0.75
        ),
        .init(
            id: "close_grip_bench_press",
            name: "Close-Grip Bench Press",
            muscles: [.init(.triceps, factor: 1.0), .init(.chest, factor: 0.55), .init(.frontDelts, factor: 0.25)],
            equipment: "barbell",
            fatigueCost: 1.05
        ),
        .init(
            id: "assisted_dip",
            name: "Assisted Dip",
            muscles: [.init(.triceps, factor: 1.0), .init(.chest, factor: 0.45), .init(.frontDelts, factor: 0.2)],
            equipment: "machine",
            fatigueCost: 0.90
        ),

        // MARK: Biceps
        .init(
            id: "dumbbell_curl",
            name: "Dumbbell Curl",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        .init(
            id: "incline_dumbbell_curl",
            name: "Incline Dumbbell Curl",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        .init(
            id: "hammer_curl",
            name: "Hammer Curl",
            muscles: [.init(.biceps, factor: 0.9)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        .init(
            id: "cable_curl",
            name: "Cable Curl",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.60
        ),
        .init(
            id: "preacher_curl",
            name: "Preacher Curl Machine",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.60
        ),
        .init(
            id: "barbell_curl",
            name: "Barbell Curl",
            muscles: [.init(.biceps, factor: 1.0)],
            equipment: "barbell",
            fatigueCost: 0.70
        ),

        // MARK: Traps
        .init(
            id: "dumbbell_shrug",
            name: "Dumbbell Shrug",
            muscles: [.init(.traps, factor: 1.0)],
            equipment: "dumbbell",
            fatigueCost: 0.65
        ),
        .init(
            id: "barbell_shrug",
            name: "Barbell Shrug",
            muscles: [.init(.traps, factor: 1.0)],
            equipment: "barbell",
            fatigueCost: 0.70
        ),
        .init(
            id: "machine_shrug",
            name: "Machine Shrug",
            muscles: [.init(.traps, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.65
        ),

        // MARK: Abs
        .init(
            id: "cable_crunch",
            name: "Cable Crunch",
            muscles: [.init(.abs, factor: 1.0)],
            equipment: "cable",
            fatigueCost: 0.55
        ),
        .init(
            id: "hanging_knee_raise",
            name: "Hanging Knee Raise",
            muscles: [.init(.abs, factor: 1.0)],
            equipment: "bodyweight",
            fatigueCost: 0.65
        ),
        .init(
            id: "ab_crunch_machine",
            name: "Ab Crunch Machine",
            muscles: [.init(.abs, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.55
        ),
        .init(
            id: "reverse_crunch",
            name: "Reverse Crunch",
            muscles: [.init(.abs, factor: 1.0)],
            equipment: "bodyweight",
            fatigueCost: 0.55
        ),

        // MARK: Quads / glutes
        .init(
            id: "back_squat",
            name: "Back Squat",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.7), .init(.hamstrings, factor: 0.2)],
            equipment: "barbell",
            fatigueCost: 1.35
        ),
        .init(
            id: "front_squat",
            name: "Front Squat",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.55)],
            equipment: "barbell",
            fatigueCost: 1.30
        ),
        .init(
            id: "leg_press",
            name: "Leg Press",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.55)],
            equipment: "machine",
            fatigueCost: 1.1
        ),
        .init(
            id: "hack_squat",
            name: "Hack Squat",
            muscles: [.init(.quads, factor: 1.0), .init(.glutes, factor: 0.55)],
            equipment: "machine",
            fatigueCost: 1.10
        ),
        .init(
            id: "leg_extension",
            name: "Leg Extension",
            muscles: [.init(.quads, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.65
        ),
        .init(
            id: "bulgarian_split_squat",
            name: "Dumbbell Bulgarian Split Squat",
            muscles: [.init(.quads, factor: 0.9), .init(.glutes, factor: 0.8)],
            equipment: "dumbbell",
            fatigueCost: 1.10
        ),
        .init(
            id: "goblet_squat",
            name: "Goblet Squat",
            muscles: [.init(.quads, factor: 0.9), .init(.glutes, factor: 0.65)],
            equipment: "dumbbell",
            fatigueCost: 0.95
        ),
        .init(
            id: "walking_lunge",
            name: "Dumbbell Walking Lunge",
            muscles: [.init(.quads, factor: 0.85), .init(.glutes, factor: 0.85)],
            equipment: "dumbbell",
            fatigueCost: 1.05
        ),

        // MARK: Hamstrings / glutes
        .init(
            id: "romanian_deadlift",
            name: "Romanian Deadlift",
            muscles: [.init(.hamstrings, factor: 1.0), .init(.glutes, factor: 0.75), .init(.back, factor: 0.15)],
            equipment: "barbell",
            fatigueCost: 1.25
        ),
        .init(
            id: "dumbbell_romanian_deadlift",
            name: "Dumbbell Romanian Deadlift",
            muscles: [.init(.hamstrings, factor: 1.0), .init(.glutes, factor: 0.75), .init(.back, factor: 0.10)],
            equipment: "dumbbell",
            fatigueCost: 1.10
        ),
        .init(
            id: "leg_curl",
            name: "Seated Leg Curl",
            muscles: [.init(.hamstrings, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.75
        ),
        .init(
            id: "lying_leg_curl",
            name: "Lying Leg Curl",
            muscles: [.init(.hamstrings, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.75
        ),
        .init(
            id: "barbell_hip_thrust",
            name: "Barbell Hip Thrust",
            muscles: [.init(.glutes, factor: 1.0), .init(.hamstrings, factor: 0.3)],
            equipment: "barbell",
            fatigueCost: 1.00
        ),
        .init(
            id: "machine_hip_thrust",
            name: "Machine Hip Thrust",
            muscles: [.init(.glutes, factor: 1.0), .init(.hamstrings, factor: 0.25)],
            equipment: "machine",
            fatigueCost: 0.90
        ),
        .init(
            id: "cable_pull_through",
            name: "Cable Pull-Through",
            muscles: [.init(.glutes, factor: 0.9), .init(.hamstrings, factor: 0.65)],
            equipment: "cable",
            fatigueCost: 0.75
        ),
        .init(
            id: "bodyweight_glute_bridge",
            name: "Glute Bridge",
            muscles: [.init(.glutes, factor: 1.0), .init(.hamstrings, factor: 0.25)],
            equipment: "bodyweight",
            fatigueCost: 0.65
        ),

        // MARK: Calves
        .init(
            id: "standing_calf_raise",
            name: "Standing Calf Raise",
            muscles: [.init(.calves, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.6
        ),
        .init(
            id: "seated_calf_raise",
            name: "Seated Calf Raise",
            muscles: [.init(.calves, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.60
        ),
        .init(
            id: "calf_press",
            name: "Leg Press Calf Press",
            muscles: [.init(.calves, factor: 1.0)],
            equipment: "machine",
            fatigueCost: 0.60
        ),
        .init(
            id: "single_leg_calf_raise",
            name: "Single-Leg Calf Raise",
            muscles: [.init(.calves, factor: 1.0)],
            equipment: "bodyweight",
            fatigueCost: 0.60
        )
    ]
}
