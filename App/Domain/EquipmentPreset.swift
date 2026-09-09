import Foundation

enum EquipmentPreset: String, CaseIterable, Identifiable {
    case fullGym
    case machinesAndCables
    case freeWeights
    case dumbbellsOnly
    case machinesOnly
    case cablesOnly
    case bodyweightOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullGym: return "Full gym"
        case .machinesAndCables: return "Machines + cables"
        case .freeWeights: return "Barbell + dumbbells"
        case .dumbbellsOnly: return "Dumbbells only"
        case .machinesOnly: return "Machines only"
        case .cablesOnly: return "Cables only"
        case .bodyweightOnly: return "Bodyweight only"
        }
    }

    var equipment: Set<String> {
        switch self {
        case .fullGym: return []
        case .machinesAndCables: return ["machine", "cable", "bodyweight"]
        case .freeWeights: return ["barbell", "dumbbell", "bodyweight"]
        case .dumbbellsOnly: return ["dumbbell", "bodyweight"]
        case .machinesOnly: return ["machine", "bodyweight"]
        case .cablesOnly: return ["cable", "bodyweight"]
        case .bodyweightOnly: return ["bodyweight"]
        }
    }
}
