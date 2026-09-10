import SwiftUI
import UniformTypeIdentifiers

struct LocalBackupView: View {
    @EnvironmentObject private var store: AppStore

    @State private var exportDocument: FitOSBackupDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var pendingArchive: FitOSBackupArchive?
    @State private var showRestoreConfirmation = false
    @State private var statusMessage: String?

    var body: some View {
        Form {
            Section("Export") {
                Button {
                    prepareExport()
                } label: {
                    Label("Export FitOS backup", systemImage: "square.and.arrow.up")
                }

                Text("Creates a plain JSON file containing your FitOS workouts, body data, targets, nutrition logs, exercise preferences, plan-adherence records, and beta workout ratings.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Import") {
                Button {
                    isImporting = true
                } label: {
                    Label("Import FitOS backup", systemImage: "square.and.arrow.down")
                }

                Text("FitOS validates the archive before offering to restore it. Nothing on this device is replaced until you confirm.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Privacy") {
                Label("Backup files are not encrypted", systemImage: "exclamationmark.shield")
                Text("Treat an exported backup as sensitive fitness data. For this HealthKit-enabled beta, keep exported backups in local device storage such as On My iPhone rather than iCloud Drive. FitOS never uploads backup files to iCloud automatically. Keychain tokens, cloud credentials, and Apple Health authorization are never included.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let pendingArchive {
                Section("Ready to restore") {
                    LabeledContent("Created") {
                        Text(pendingArchive.generatedAt, style: .date)
                    }
                    LabeledContent("Workouts", value: String(pendingArchive.sessions.count))
                    LabeledContent("Body records", value: String(pendingArchive.measurements.count))
                    LabeledContent("Nutrition entries", value: String(pendingArchive.nutritionEntries.count))
                    LabeledContent("Plan records", value: String(pendingArchive.planAdherenceRecords.count))

                    Button("Replace local FitOS data", role: .destructive) {
                        showRestoreConfirmation = true
                    }
                }
            }

            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Local backup")
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "FitOS-Backup"
        ) { result in
            switch result {
            case .success:
                statusMessage = "Backup exported. Keep the file in local device storage for this beta."
            case .failure(let error):
                statusMessage = "Export failed: \(error.localizedDescription)"
            }
            exportDocument = nil
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            handleImport(result)
        }
        .confirmationDialog(
            "Replace this device's FitOS data?",
            isPresented: $showRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("Replace local data", role: .destructive) {
                restorePendingArchive()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Current FitOS workouts, body records, targets, nutrition, preferences, plan-adherence records, and beta ratings will be replaced. Apple Health authorization is not changed.")
        }
    }

    private func prepareExport() {
        do {
            let archive = store.makeLocalBackupArchive()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            exportDocument = FitOSBackupDocument(data: try encoder.encode(archive))
            isExporting = true
        } catch {
            statusMessage = "Could not prepare backup: \(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            statusMessage = "Import failed: \(error.localizedDescription)"
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let archive = try decoder.decode(FitOSBackupArchive.self, from: data)
                try archive.validate()
                pendingArchive = archive
                statusMessage = "Backup validated. Review the counts below before restoring."
            } catch {
                pendingArchive = nil
                statusMessage = "This file is not a supported FitOS backup: \(error.localizedDescription)"
            }
        }
    }

    private func restorePendingArchive() {
        guard let archive = pendingArchive else { return }
        do {
            try store.restoreFromLocalBackup(archive)
            pendingArchive = nil
            statusMessage = "Local FitOS data restored from backup."
        } catch {
            statusMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
}
