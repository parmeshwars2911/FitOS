import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            Group {
                if store.sessions.isEmpty {
                    ContentUnavailableView(
                        "No workouts yet",
                        systemImage: "calendar.badge.plus",
                        description: Text("Complete your first workout and FitOS will begin learning your training state.")
                    )
                } else {
                    List {
                        if let acceptance = store.generatedExerciseAcceptanceRate {
                            Section("Train Today feedback") {
                                LabeledContent("Exercise acceptance") {
                                    Text("\(Int((acceptance * 100).rounded()))%")
                                        .fontWeight(.semibold)
                                }
                                Text("Share of FitOS-generated exercises completed without replacing or skipping them.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        let strengthTrends = store.recentStrengthTrends()
                        if !strengthTrends.isEmpty {
                            Section("Estimated strength") {
                                ForEach(strengthTrends) { trend in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(trend.exerciseName)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text("e1RM \(trend.latestEstimated1RMKg, specifier: "%.1f") kg")
                                                .font(.caption.monospacedDigit())
                                        }
                                        if let change = trend.percentChangeFromPrevious {
                                            Text("\(signedPercent(change)) vs previous session · best \(trend.bestEstimated1RMKg, specifier: "%.1f") kg")
                                                .font(.caption)
                                                .foregroundStyle(change >= 0 ? Color.green : Color.secondary)
                                        } else {
                                            Text("First strength estimate · best \(trend.bestEstimated1RMKg, specifier: "%.1f") kg")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }

                        Section("Workouts") {
                            ForEach(store.sessions) { session in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(session.completedAt, style: .date)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("\(totalSets(in: session)) sets")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(session.exercises.map { $0.exercise.name }.joined(separator: " · "))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: store.deleteSessions)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    private func totalSets(in session: WorkoutSession) -> Int {
        session.exercises.reduce(0) { $0 + $1.sets.count }
    }

    private func signedPercent(_ value: Double) -> String {
        String(format: "%+.1f%%", value)
    }
}
