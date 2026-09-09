import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "bolt.heart.fill")
                }

            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife")
                }

            BodyProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.xyaxis.line")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            TrainingGoalsView()
                .tabItem {
                    Label("Goals", systemImage: "scope")
                }
        }
    }
}
