import SwiftUI

@main
struct FitOSApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var cloud = CloudAccountStore()
    @AppStorage("fitos-onboarding-completed") private var onboardingCompleted = false

    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingCompleted {
                    RootView()
                        .task {
                            await store.syncHealthKitIfEnabled()
                        }
                } else {
                    OnboardingView {
                        onboardingCompleted = true
                    }
                }
            }
            .environmentObject(store)
            .environmentObject(cloud)
        }
    }
}
