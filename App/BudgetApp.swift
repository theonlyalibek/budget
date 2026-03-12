import SwiftUI
import SwiftData

@main
struct BudgetApp: App {
    @StateObject private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
        .modelContainer(container.modelContainer)
    }
}
