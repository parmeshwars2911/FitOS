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

                    NavigationLink {
                        ExercisePreferencesView()
                    } label: {
                        Label("Exercise preferences", systemImage: "slider.horizontal.3")
                    }
                }

                Section("Beta") {
                    NavigationLink {
                        BetaMetricsView()
                    } label: {
                        Label("Beta metrics", systemImage: "chart.bar.xaxis")
                    }
                }

                Section("Data") {
                    NavigationLink {
                        CloudSettingsView()
                    } label: {
                        Label("Cloud & AI", systemImage: "icloud")
                    }

                    NavigationLink {
                        AIContextShareView()
                    } label: {
                        Label("Share AI context", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
