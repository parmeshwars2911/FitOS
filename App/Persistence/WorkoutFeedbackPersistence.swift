import Foundation

final class WorkoutFeedbackPersistence {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("fitos-workout-feedback.json")
    }

    func load() -> [WorkoutRecommendationFeedback] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([WorkoutRecommendationFeedback].self, from: data)) ?? []
    }

    func save(_ records: [WorkoutRecommendationFeedback]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
