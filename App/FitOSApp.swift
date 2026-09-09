import SwiftUI

@main
struct FitOSApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .task {
                    await store.syncHealthKitIfEnabled()
                }
        }
    }
}
