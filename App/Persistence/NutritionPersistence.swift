import Foundation

struct NutritionSnapshot: Codable {
    var entries: [NutritionEntry]
    var target: NutritionTarget
}

final class NutritionPersistence {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("fitos-nutrition.json")
        LocalDataProtection.protectExistingFile(at: self.fileURL)
    }

    func load() -> NutritionSnapshot {
        guard let data = try? Data(contentsOf: fileURL) else {
            return NutritionSnapshot(entries: [], target: .unset)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(NutritionSnapshot.self, from: data))
            ?? NutritionSnapshot(entries: [], target: .unset)
    }

    func save(entries: [NutritionEntry], target: NutritionTarget) {
        let snapshot = NutritionSnapshot(entries: entries, target: target)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        LocalDataProtection.write(data, to: fileURL)
    }
}
