import XCTest
@testable import budget

final class DashboardStatsTests: XCTestCase {

    // MARK: - balance computed property

    func test_balance_positiveWhenIncomeExceedsExpenses() {
        let stats = DashboardStats(totalIncome: 200_000, totalExpenses: 150_000,
                                   expensesByCategory: [:])
        XCTAssertEqual(stats.balance, 50_000, accuracy: 0.01)
    }

    func test_balance_negativeWhenExpensesExceedIncome() {
        let stats = DashboardStats(totalIncome: 100_000, totalExpenses: 180_000,
                                   expensesByCategory: [:])
        XCTAssertEqual(stats.balance, -80_000, accuracy: 0.01)
    }

    func test_balance_zeroWhenEqual() {
        let stats = DashboardStats(totalIncome: 75_000, totalExpenses: 75_000,
                                   expensesByCategory: [:])
        XCTAssertEqual(stats.balance, 0, accuracy: 0.01)
    }

    // MARK: - empty sentinel

    func test_empty_allFieldsAreZero() {
        let stats = DashboardStats.empty
        XCTAssertEqual(stats.totalIncome, 0)
        XCTAssertEqual(stats.totalExpenses, 0)
        XCTAssertEqual(stats.balance, 0)
        XCTAssertTrue(stats.expensesByCategory.isEmpty)
    }

    // MARK: - expensesByCategory integrity

    func test_expensesByCategory_valuesArePreserved() {
        let breakdown: [Category: Double] = [.food: 30_000, .transport: 15_000]
        let stats = DashboardStats(totalIncome: 0, totalExpenses: 45_000,
                                   expensesByCategory: breakdown)
        XCTAssertEqual(stats.expensesByCategory[.food], 30_000)
        XCTAssertEqual(stats.expensesByCategory[.transport], 15_000)
    }

    func test_expensesByCategory_missingCategory_returnsNil() {
        let stats = DashboardStats(totalIncome: 0, totalExpenses: 0,
                                   expensesByCategory: [:])
        XCTAssertNil(stats.expensesByCategory[.entertainment])
    }
}
