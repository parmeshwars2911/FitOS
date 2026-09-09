import Foundation

enum DefaultTargets {
    static let all: [MuscleTarget] = [
        .init(muscle: .chest, effectiveSetsPer7Days: 12, fullRecoveryHours: 48),
        .init(muscle: .back, effectiveSetsPer7Days: 14, fullRecoveryHours: 48),
        .init(muscle: .frontDelts, effectiveSetsPer7Days: 7, fullRecoveryHours: 48),
        .init(muscle: .sideDelts, effectiveSetsPer7Days: 10, goalPriority: 1.1, fullRecoveryHours: 36),
        .init(muscle: .rearDelts, effectiveSetsPer7Days: 8, fullRecoveryHours: 36),
        .init(muscle: .triceps, effectiveSetsPer7Days: 10, fullRecoveryHours: 36),
        .init(muscle: .biceps, effectiveSetsPer7Days: 10, fullRecoveryHours: 36),
        .init(muscle: .traps, effectiveSetsPer7Days: 6, fullRecoveryHours: 36),
        .init(muscle: .abs, effectiveSetsPer7Days: 8, fullRecoveryHours: 24),
        .init(muscle: .quads, effectiveSetsPer7Days: 12, fullRecoveryHours: 60),
        .init(muscle: .hamstrings, effectiveSetsPer7Days: 10, fullRecoveryHours: 60),
        .init(muscle: .glutes, effectiveSetsPer7Days: 10, fullRecoveryHours: 60),
        .init(muscle: .calves, effectiveSetsPer7Days: 8, fullRecoveryHours: 36)
    ]
}
