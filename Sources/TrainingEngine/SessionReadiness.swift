import Foundation

public enum SessionReadiness: String, CaseIterable, Codable, Sendable, Equatable {
    case low
    case normal
    case high

    public var setBudgetMultiplier: Double {
        switch self {
        case .low: return 0.75
        case .normal, .high: return 1.0
        }
    }

    public var targetRIRDescription: String {
        switch self {
        case .low: return "~3 RIR"
        case .normal: return "~2 RIR"
        case .high: return "~1–2 RIR"
        }
    }
}
