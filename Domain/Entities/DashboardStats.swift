import Foundation

/// Aggregated stats for the Dashboard view.
struct DashboardStats: Sendable {
    let totalIncome: Double
    let totalExpenses: Double
    /// Keyed by category storage string (enum rawValue or "custom:<UUID>").
    let expensesByCategory: [String: Double]

    var balance: Double {
        totalIncome - totalExpenses
    }

    static let empty = DashboardStats(
        totalIncome: 0,
        totalExpenses: 0,
        expensesByCategory: [:]
    )
}
