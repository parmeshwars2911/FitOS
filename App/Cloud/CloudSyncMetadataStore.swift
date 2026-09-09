import Foundation

struct CloudSyncMetadata: Codable, Equatable {
    let revision: Int64
    let lastSyncedAt: Date
}

struct CloudSyncMetadataStore {
    private let defaults: UserDefaults
    private let prefix = "fitos-cloud-sync-metadata-"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(userID: UUID) -> CloudSyncMetadata? {
        guard let data = defaults.data(forKey: key(userID)) else { return nil }
        return try? JSONDecoder().decode(CloudSyncMetadata.self, from: data)
    }

    func save(_ metadata: CloudSyncMetadata, userID: UUID) {
        guard let data = try? JSONEncoder().encode(metadata) else { return }
        defaults.set(data, forKey: key(userID))
    }

    private func key(_ userID: UUID) -> String {
        prefix + userID.uuidString.lowercased()
    }
}
