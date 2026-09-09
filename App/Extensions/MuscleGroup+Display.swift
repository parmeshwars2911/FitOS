import Foundation

extension MuscleGroup {
    var displayName: String {
        switch self {
        case .chest: return "Chest"
        case .back: return "Back"
        case .frontDelts: return "Front delts"
        case .sideDelts: return "Side delts"
        case .rearDelts: return "Rear delts"
        case .triceps: return "Triceps"
        case .biceps: return "Biceps"
        case .traps: return "Traps"
        case .abs: return "Abs"
        case .quads: return "Quads"
        case .hamstrings: return "Hamstrings"
        case .glutes: return "Glutes"
        case .calves: return "Calves"
        }
    }
}
