import SwiftUI

struct WeeklyReviewView: View {
    @EnvironmentObject private var store: AppStore

    private var review: WeeklyReview {
        store.weeklyReview
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(review.headline)
                        .font(.title3.bold())
                    Text("Data confidence: \(review.confidence.rawValue.capitalized)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("This review is generated from deterministic FitOS calculations. It is not an LLM response.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("What stands out") {
                ForEach(review.observations) { observation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: icon(for: observation.kind))
                            .foregroundStyle(color(for: observation.kind))
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(observation.title)
                                .fontWeight(.semibold)
                            Text(observation.message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("AI-ready context") {
                Text("FitOS now builds one Codable context object from training state, body trends and nutrition adherence. A future built-in AI or MCP server can consume this same contract instead of independently interpreting raw logs.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Weekly Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func icon(for kind: CoachObservationKind) -> String {
        switch kind {
        case .positive: "checkmark.circle.fill"
        case .attention: "exclamationmark.triangle.fill"
        case .information: "info.circle.fill"
        }
    }

    private func color(for kind: CoachObservationKind) -> Color {
        switch kind {
        case .positive: .green
        case .attention: .orange
        case .information: .secondary
        }
    }
}
