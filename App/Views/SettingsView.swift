import SwiftUI

struct SettingsView: View {
    private let privacyPolicyURL = URL(string: "https://github.com/parmeshwars2911/FitOS/blob/main/PRIVACY_POLICY.md")!
    private let supportURL = URL(string: "https://github.com/parmeshwars2911/FitOS/issues")!

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
                        LocalBackupView()
                    } label: {
                        Label("Local backup", systemImage: "externaldrive")
                    }

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

                Section("About") {
                    Link(destination: privacyPolicyURL) {
                        Label("Privacy policy", systemImage: "hand.raised")
                    }

                    Link(destination: supportURL) {
                        Label("Support & feedback", systemImage: "questionmark.bubble")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
