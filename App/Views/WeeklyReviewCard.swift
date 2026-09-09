import SwiftUI

struct WeeklyReviewCard: View {
    @EnvironmentObject private var store: AppStore

    private var review: WeeklyReview {
        store.weeklyReview
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("FitOS Review", systemImage: "sparkles.rectangle.stack")
                    .font(.headline)
                Spacer()
                Text(review.confidence.rawValue.capitalized)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text(review.headline)
                .font(.subheadline)

            if let first = review.observations.first {
                Text(first.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            NavigationLink("Open weekly review") {
                WeeklyReviewView()
                    .environmentObject(store)
            }
            .font(.subheadline.bold())
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
