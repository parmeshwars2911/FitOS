import SwiftUI

struct AIContextShareView: View {
    @EnvironmentObject private var store: AppStore

    private var exportText: String {
        store.makeAIContextExportJSON() ?? "{}"
    }

    var body: some View {
        Form {
            Section("Share with an AI") {
                Text("FitOS can package its deterministic coaching context into JSON that you choose to share with ChatGPT, Claude, or another assistant.")
                    .foregroundStyle(.secondary)

                ShareLink(
                    item: exportText,
                    subject: Text("FitOS coaching context"),
                    message: Text("Use this FitOS context to help me review my recent training, nutrition, and body trends. Distinguish recorded facts from inference.")
                ) {
                    Label("Share AI context", systemImage: "square.and.arrow.up")
                }
            }

            Section("Included") {
                LabeledContent("Recent workouts", value: String(store.coachContext.recentWorkoutCount))
                LabeledContent("Nutrition days logged", value: "\(store.coachContext.recentNutrition.daysWithEntries)/7")
                LabeledContent("Weight trend") {
                    Text(store.coachContext.weightTrend14Days == nil ? "Not enough data" : "Included")
                }
                LabeledContent("Weekly review", value: store.weeklyReview.confidence.rawValue.capitalized)
            }

            Section("Privacy") {
                Text("This export contains summarized FitOS context and the deterministic weekly review, not your account token or cloud credentials. FitOS does not send it anywhere until you use the Share button.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("JSON preview") {
                Text(exportText)
                    .font(.system(.caption, design: .monospaced))
                    .textSelection(.enabled)
                    .lineLimit(16)
            }
        }
        .navigationTitle("Share AI Context")
    }
}
