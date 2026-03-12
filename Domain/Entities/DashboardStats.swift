import Foundation

/// Aggregated stats for the Dashboard view.
struct DashboardStats: Sendable {
    let totalIncome: Double
    let totalExpenses: Double
    let expensesByCategory: [Category: Double]

    var balance: Double {
        totalIncome - totalExpenses
    }

    static let empty = DashboardStats(
        totalIncome: 0,
        totalExpenses: 0,
        expensesByCategory: [:]
    )
}
