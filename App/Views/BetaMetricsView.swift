import SwiftUI

struct BetaMetricsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        List {
            Section("Generated workout acceptance") {
                metric(
                    title: "Exercise acceptance",
                    value: store.generatedExerciseAcceptanceRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                    detail: "Share of planned exercises completed without replacement or skipping."
                )
            }

            Section("Recommendation usefulness") {
                let summary = store.workoutFeedbackSummary
                metric(
                    title: "Average rating",
                    value: summary.averageRating.map { String(format: "%.1f / 5", $0) } ?? "—",
                    detail: "Across \(summary.ratingCount) rated generated workout\(summary.ratingCount == 1 ? "" : "s")."
                )
                metric(
                    title: "Rated 4–5",
                    value: summary.favorableRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                    detail: "The beta target is an average usefulness rating of at least 4/5."
                )
            }

            Section {
                Text("These metrics are calculated on-device from FitOS workout records. The first beta does not send them to a third-party analytics service.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Beta metrics")
    }

    private func metric(title: String, value: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                Spacer()
                Text(value).fontWeight(.semibold)
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}
