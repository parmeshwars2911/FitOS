import Foundation

@MainActor
extension AppStore {
    func makeAIContextExportJSON(prettyPrinted: Bool = true) -> String? {
        let export = AIContextExport(
            coachContext: coachContext,
            weeklyReview: weeklyReview
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if prettyPrinted {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        }
        guard let data = try? encoder.encode(export) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
