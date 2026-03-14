import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var customCategories: [CustomCategorySnapshot] = []

    var body: some View {
        TabView {
            Tab(String(localized: "tab_dashboard"), systemImage: "chart.pie.fill") {
                DashboardView(
                    viewModel: DashboardViewModel(
                        getStatsUseCase: container.getDashboardStatsUseCase
                    ),
                    customCategories: customCategories
                )
            }

            Tab(String(localized: "tab_history"), systemImage: "list.bullet") {
                HistoryView(
                    viewModel: HistoryViewModel(
                        repository: container.transactionRepository
                    ),
                    customCategories: customCategories
                )
            }

            Tab(String(localized: "tab_add"), systemImage: "plus.circle.fill") {
                AddTransactionView(
                    viewModel: AddTransactionViewModel(
                        addTransactionUseCase: container.addTransactionUseCase,
                        customCategories: customCategories
                    )
                )
            }

            Tab(String(localized: "tab_analytics"), systemImage: "chart.bar.fill") {
                AnalyticsView(
                    viewModel: AnalyticsViewModel(
                        getStatsUseCase: container.getDashboardStatsUseCase
                    ),
                    customCategories: customCategories
                )
            }

            Tab(String(localized: "tab_settings"), systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .onAppear { reloadCustomCategories() }
        .onReceive(NotificationCenter.default.publisher(for: .customCategoriesDidChange)) { _ in
            reloadCustomCategories()
        }
    }

    private func reloadCustomCategories() {
        customCategories = container.loadCustomCategorySnapshots()
    }
}

extension Notification.Name {
    /// Posted when custom categories are created, updated, or deleted.
    static let customCategoriesDidChange = Notification.Name("customCategoriesDidChange")
}
