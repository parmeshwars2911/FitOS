import SwiftUI

struct BetaMetricsView: View {
    @EnvironmentObject private var store: AppStore

    private var report: BetaReport { store.betaReport }

    var body: some View {
        List {
            Section("Generated workout acceptance") {
                metric(
                    title: "Exercise acceptance",
                    value: report.exerciseAcceptanceRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                    detail: "Accepted planned exercises divided by all planned exercises across generated workouts."
                )
                metric(
                    title: "Generated workouts",
                    value: String(report.generatedWorkoutCount),
                    detail: "Completed workouts that originated from a FitOS recommendation."
                )
                metric(
                    title: "Exercise outcomes",
                    value: "\(report.acceptedExerciseCount) / \(report.plannedExerciseCount)",
                    detail: "Accepted / planned. Replaced: \(report.replacedExerciseCount) · Skipped: \(report.skippedExerciseCount)."
                )
            }

            Section("Recommendation usefulness") {
                metric(
                    title: "Average rating",
                    value: report.averageUsefulnessRating.map { String(format: "%.1f / 5", $0) } ?? "—",
                    detail: "Across \(report.ratedWorkoutCount) rated generated workout\(report.ratedWorkoutCount == 1 ? "" : "s")."
                )
                metric(
                    title: "Rated 4–5",
                    value: report.favorableWorkoutRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                    detail: "The beta target is an average usefulness rating of at least 4/5."
                )
            }

            Section("Share aggregate beta report") {
                ShareLink(
                    item: store.betaReportExportJSON,
                    subject: Text("FitOS beta metrics"),
                    message: Text("Aggregate FitOS beta metrics from this device. This report excludes individual workout, body, nutrition and HealthKit records.")
                ) {
                    Label("Share beta report", systemImage: "square.and.arrow.up")
                }

                Text("The shared JSON contains app/build version and aggregate counts, rates and feedback-reason totals only. It does not contain workout IDs, exercise IDs, set/load/reps, body measurements, nutrition values, HealthKit data, account details or device identifiers.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("These metrics are calculated on-device. FitOS does not upload beta analytics automatically; nothing leaves the device until you choose a destination in the system share sheet.")
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
