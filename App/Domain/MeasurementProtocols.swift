import Foundation

struct BodyMeasurementProtocol {
    let kind: BodyMetricKind
    let summary: String
    let steps: [String]
}

enum MeasurementProtocols {
    static func protocolFor(_ kind: BodyMetricKind) -> BodyMeasurementProtocol {
        switch kind {
        case .weightKg:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Make weigh-ins comparable by keeping the scale and conditions similar.",
                steps: [
                    "Use the same scale on a hard, level surface.",
                    "Prefer a similar time of day and similar clothing each time.",
                    "Stand centered and still until the reading settles."
                ]
            )
        case .heightCm:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Height is mainly profile context, so consistency matters more than frequent logging.",
                steps: [
                    "Measure barefoot on a hard floor.",
                    "Stand tall against a wall with your head level and eyes forward.",
                    "Keep the measuring surface horizontal when marking the top of the head."
                ]
            )
        case .bodyFatPercent:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Body-fat devices can move with hydration and method, so compare like with like.",
                steps: [
                    "Use the same device or measurement method each time.",
                    "Measure under similar hydration, meal and exercise conditions when practical.",
                    "Treat the result as a trend estimate rather than an exact body-fat measurement."
                ]
            )
        case .waistCm:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Use one repeatable waist landmark and keep the tape level.",
                steps: [
                    "Stand relaxed with feet about hip-width apart and abdomen unflexed.",
                    "Use the same landmark every time; FitOS recommends the midpoint between the lower rib and top of the hip bone.",
                    "Keep the tape horizontal and snug without compressing the skin.",
                    "Read after a normal exhale, then repeat without intentionally tightening the tape."
                ]
            )
        case .chestCm:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Chest circumference is sensitive to tape angle and breathing.",
                steps: [
                    "Stand naturally with arms relaxed by your sides.",
                    "Place the tape level around the same fullest-chest landmark each time.",
                    "Keep it snug without compressing the skin.",
                    "Take the reading at a consistent point in a normal breath, then repeat."
                ]
            )
        case .bicepsCm:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Small changes in tape position can create a large apparent arm change.",
                steps: [
                    "Use the same arm and the same relaxed or flexed condition every time; FitOS recommends relaxed for repeatability.",
                    "Use the same midpoint between shoulder and elbow as your landmark.",
                    "Keep the tape perpendicular to the arm and snug without pressing into the skin.",
                    "Repeat from a fully reset tape position rather than just rereading the first placement."
                ]
            )
        case .thighCm:
            return BodyMeasurementProtocol(
                kind: kind,
                summary: "Thigh readings change quickly if the tape moves up or down the leg.",
                steps: [
                    "Use the same leg and stand with weight distributed similarly each time.",
                    "Choose a fixed landmark, such as the midpoint between hip crease and top of the kneecap, and reuse it.",
                    "Keep the tape horizontal and snug without compressing the skin.",
                    "Repeat after removing and replacing the tape."
                ]
            )
        }
    }
}
