import SwiftUI

@main
struct FitOSApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var cloudAccount = CloudAccountStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(cloudAccount)
                .task {
                    await store.syncHealthKitIfEnabled()
                }
        }
    }
}
