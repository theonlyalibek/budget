import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {

    // MARK: - State

    private(set) var stats: DashboardStats = .empty
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let getStatsUseCase: GetDashboardStatsUseCase

    // MARK: - Init

    init(getStatsUseCase: GetDashboardStatsUseCase) {
        self.getStatsUseCase = getStatsUseCase
    }

    // MARK: - Actions

    func loadStats() {
        isLoading = true
        errorMessage = nil

        do {
            stats = try getStatsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
            stats = .empty
        }

        isLoading = false
    }

    /// Sorted categories for the pie chart — largest slice first.
    var sortedExpenses: [(category: Category, amount: Double)] {
        stats.expensesByCategory
            .sorted { $0.value > $1.value }
            .map { (category: $0.key, amount: $0.value) }
    }
}
