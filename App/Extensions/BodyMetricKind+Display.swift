import Foundation

extension BodyMetricKind {
    var displayName: String {
        switch self {
        case .weightKg: "Weight"
        case .heightCm: "Height"
        case .bodyFatPercent: "Body fat"
        case .waistCm: "Waist"
        case .chestCm: "Chest"
        case .bicepsCm: "Biceps"
        case .thighCm: "Thigh"
        }
    }

    var unit: String {
        switch self {
        case .weightKg: "kg"
        case .bodyFatPercent: "%"
        case .heightCm, .waistCm, .chestCm, .bicepsCm, .thighCm: "cm"
        }
    }

    var iconName: String {
        switch self {
        case .weightKg: "scalemass.fill"
        case .heightCm: "ruler.fill"
        case .bodyFatPercent: "percent"
        case .waistCm: "circle.dashed"
        case .chestCm: "figure.strengthtraining.traditional"
        case .bicepsCm: "dumbbell.fill"
        case .thighCm: "figure.walk"
        }
    }
}
