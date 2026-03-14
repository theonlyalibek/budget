import Foundation
import Observation

/// Period for analytics grouping.
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var localizedKey: String {
        switch self {
        case .week:  "period_week"
        case .month: "period_month"
        case .year:  "period_year"
        }
    }

    func dateRange(from now: Date = .now) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch self {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return (start, now)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return (start, now)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (start, now)
        }
    }
}

@MainActor
@Observable
final class AnalyticsViewModel {

    // MARK: - State

    var selectedPeriod: AnalyticsPeriod = .month
    private(set) var stats: DashboardStats = .empty
    private(set) var isLoading = false

    var sortedExpenses: [(category: Category, amount: Double)] {
        stats.expensesByCategory
            .sorted { $0.value > $1.value }
            .map { (category: $0.key, amount: $0.value) }
    }

    // MARK: - Dependencies

    private let getStatsUseCase: GetDashboardStatsUseCase

    // MARK: - Init

    init(getStatsUseCase: GetDashboardStatsUseCase) {
        self.getStatsUseCase = getStatsUseCase
    }

    // MARK: - Actions

    func loadStats() {
        isLoading = true
        let range = selectedPeriod.dateRange()
        do {
            stats = try getStatsUseCase.execute(startDate: range.start, endDate: range.end)
        } catch {
            stats = .empty
        }
        isLoading = false
    }
}
