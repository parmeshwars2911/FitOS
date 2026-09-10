import Foundation

enum LocalDataProtection {
    static func protectExistingFile(at fileURL: URL) {
        excludeFromBackup(fileURL)
    }

    static func write(_ data: Data, to fileURL: URL) {
        do {
            try data.write(to: fileURL, options: .atomic)
            excludeFromBackup(fileURL)
        } catch {
            // Persistence is intentionally best-effort in the local-first beta.
        }
    }

    private static func excludeFromBackup(_ fileURL: URL) {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableURL = fileURL
        try? mutableURL.setResourceValues(values)
    }
}
