import Foundation

final class WorkoutPlanAdherencePersistence {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("fitos-plan-adherence.json")
        LocalDataProtection.protectExistingFile(at: self.fileURL)
    }

    func load() -> [WorkoutPlanAdherence] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([WorkoutPlanAdherence].self, from: data)) ?? []
    }

    func save(_ records: [WorkoutPlanAdherence]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(records) else { return }
        LocalDataProtection.write(data, to: fileURL)
    }
}
