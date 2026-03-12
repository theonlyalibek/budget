import Foundation

/// Computes aggregated income/expense stats for a given period.
@MainActor
final class GetDashboardStatsUseCase {

    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    /// Returns dashboard stats for the given date range.
    /// If no range is provided, returns stats for the current calendar month.
    func execute(startDate: Date? = nil, endDate: Date? = nil) throws -> DashboardStats {
        let (start, end) = resolveDateRange(startDate: startDate, endDate: endDate)

        let filter = TransactionFilter(startDate: start, endDate: end)
        let transactions = try repository.fetch(filter: filter)

        var totalIncome: Double = 0
        var totalExpenses: Double = 0
        var expensesByCategory: [Category: Double] = [:]

        for transaction in transactions {
            if transaction.isIncome {
                totalIncome += transaction.amount
            } else {
                totalExpenses += transaction.amount
                let category = Category(rawValue: transaction.category) ?? .other
                expensesByCategory[category, default: 0] += transaction.amount
            }
        }

        return DashboardStats(
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            expensesByCategory: expensesByCategory
        )
    }

    // MARK: - Helpers

    /// Defaults to the current calendar month if no explicit range given.
    private func resolveDateRange(
        startDate: Date?,
        endDate: Date?
    ) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date.now

        let start = startDate ?? calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        ) ?? now

        let end = endDate ?? (calendar.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: start
        ) ?? now)

        return (start, end)
    }
}
