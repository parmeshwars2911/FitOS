import SwiftUI

struct RecommendationFeedbackCard: View {
    @EnvironmentObject private var store: AppStore
    @State private var rating: Int?
    @State private var reason: WorkoutFeedbackReason?

    var body: some View {
        if let sessionID = store.pendingWorkoutFeedbackSessionID {
            VStack(alignment: .leading, spacing: 12) {
                Label("Rate your FitOS workout", systemImage: "star.bubble")
                    .font(.headline)

                Text("How useful was the generated session you just completed?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            rating = value
                        } label: {
                            Image(systemName: (rating ?? 0) >= value ? "star.fill" : "star")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(value) out of 5")
                    }
                }

                if let rating, rating <= 3 {
                    Picker("What was off?", selection: $reason) {
                        Text("Choose a reason").tag(WorkoutFeedbackReason?.none)
                        ForEach(WorkoutFeedbackReason.allCases.filter { $0 != .goodBalance }, id: \.self) { item in
                            Text(item.displayName).tag(Optional(item))
                        }
                    }
                    .pickerStyle(.menu)
                }

                if let rating {
                    Button {
                        store.recordWorkoutFeedback(sessionID: sessionID, rating: rating, reason: reasonForSubmission(rating))
                        self.rating = nil
                        reason = nil
                    } label: {
                        Text("Submit rating")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(14)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func reasonForSubmission(_ rating: Int) -> WorkoutFeedbackReason? {
        if rating >= 4 { return .goodBalance }
        return reason
    }
}

private extension WorkoutFeedbackReason {
    var displayName: String {
        switch self {
        case .goodBalance: return "Good balance"
        case .wrongExercises: return "Wrong exercises"
        case .tooLong: return "Too long"
        case .tooShort: return "Too short"
        case .tooHard: return "Too hard"
        case .tooEasy: return "Too easy"
        }
    }
}
