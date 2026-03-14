import SwiftUI
import SwiftData

@main
struct BudgetApp: App {
    @StateObject private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
                // Injects LocalSubscriptionService as an @Observable environment value.
                // Child views access it via @Environment(LocalSubscriptionService.self).
                .environment(container.subscriptionService)
        }
        .modelContainer(container.modelContainer)
    }
}
