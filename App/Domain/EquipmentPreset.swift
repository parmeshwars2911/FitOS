import Foundation

enum EquipmentPreset: String, CaseIterable, Identifiable {
    case fullGym
    case machinesAndCables
    case freeWeights
    case dumbbellsOnly
    case machinesOnly
    case cablesOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fullGym: return "Full gym"
        case .machinesAndCables: return "Machines + cables"
        case .freeWeights: return "Barbell + dumbbells"
        case .dumbbellsOnly: return "Dumbbells only"
        case .machinesOnly: return "Machines only"
        case .cablesOnly: return "Cables only"
        }
    }

    var equipment: Set<String> {
        switch self {
        case .fullGym: return []
        case .machinesAndCables: return ["machine", "cable"]
        case .freeWeights: return ["barbell", "dumbbell"]
        case .dumbbellsOnly: return ["dumbbell"]
        case .machinesOnly: return ["machine"]
        case .cablesOnly: return ["cable"]
        }
    }
}
