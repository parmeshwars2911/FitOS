import Foundation

final class ActiveWorkoutPersistence {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("fitos-active-workout.json")
        LocalDataProtection.protectExistingFile(at: self.fileURL)
    }

    func load() -> ActiveWorkoutDraft? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let draft = try? decoder.decode(ActiveWorkoutDraft.self, from: data),
              draft.isSupported
        else { return nil }
        return draft
    }

    func save(_ draft: ActiveWorkoutDraft) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(draft) else { return }
        LocalDataProtection.write(data, to: fileURL)
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
