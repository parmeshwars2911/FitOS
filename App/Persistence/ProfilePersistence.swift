import Foundation

struct FitProfileSnapshot: Codable {
    var measurements: [BodyMeasurement]
    var targets: [MuscleTarget]
}

final class ProfilePersistence {
    private let fileURL: URL

    init(fileManager: FileManager = .default) {
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.fileURL = directory.appendingPathComponent("fitos-profile.json")
        LocalDataProtection.protectExistingFile(at: self.fileURL)
    }

    func load(defaultTargets: [MuscleTarget]) -> FitProfileSnapshot {
        guard let data = try? Data(contentsOf: fileURL) else {
            return FitProfileSnapshot(measurements: [], targets: defaultTargets)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard var snapshot = try? decoder.decode(FitProfileSnapshot.self, from: data) else {
            return FitProfileSnapshot(measurements: [], targets: defaultTargets)
        }

        if snapshot.targets.isEmpty {
            snapshot.targets = defaultTargets
        }
        return snapshot
    }

    func save(measurements: [BodyMeasurement], targets: [MuscleTarget]) {
        let snapshot = FitProfileSnapshot(measurements: measurements, targets: targets)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        LocalDataProtection.write(data, to: fileURL)
    }
}
