import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer

    var body: some View {
        TabView {
            Tab(String(localized: "tab_dashboard"), systemImage: "chart.pie.fill") {
                DashboardView(
                    viewModel: DashboardViewModel(
                        getStatsUseCase: container.getDashboardStatsUseCase
                    )
                )
            }

            Tab(String(localized: "tab_history"), systemImage: "list.bullet") {
                HistoryView(
                    viewModel: HistoryViewModel(
                        repository: container.transactionRepository
                    )
                )
            }

            Tab(String(localized: "tab_add"), systemImage: "plus.circle.fill") {
                AddTransactionView(
                    viewModel: AddTransactionViewModel(
                        addTransactionUseCase: container.addTransactionUseCase
                    )
                )
            }

            Tab(String(localized: "tab_analytics"), systemImage: "chart.bar.fill") {
                AnalyticsView(
                    viewModel: AnalyticsViewModel(
                        getStatsUseCase: container.getDashboardStatsUseCase
                    )
                )
            }

            Tab(String(localized: "tab_settings"), systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}
