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
            .navigationTitle("History")
        }
    }

    private func totalSets(in session: WorkoutSession) -> Int {
        session.exercises.reduce(0) { $0 + $1.sets.count }
    }
}
