import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Training") {
                    NavigationLink {
                        TrainingGoalsView()
                    } label: {
                        Label("Training goals", systemImage: "scope")
                    }
                }

                Section("Data") {
                    NavigationLink {
                        CloudSettingsView()
                    } label: {
                        Label("Cloud & AI", systemImage: "icloud")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
