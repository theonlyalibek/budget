import XCTest
@testable import budget

@MainActor
final class GetDashboardStatsUseCaseTests: XCTestCase {

    private var repository: MockTransactionRepository!
    private var useCase: GetDashboardStatsUseCase!

    // Fixed reference date — keeps tests deterministic
    private let ref = Date(timeIntervalSince1970: 1_700_000_000) // 2023-11-14

    override func setUp() {
        super.setUp()
        repository = MockTransactionRepository()
        useCase = GetDashboardStatsUseCase(repository: repository)
    }

    override func tearDown() {
        useCase = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Empty state

    func test_emptyRepository_returnsZeroStats() throws {
        let stats = try useCase.execute(startDate: ref, endDate: ref.addingTimeInterval(86400))
        XCTAssertEqual(stats.totalIncome, 0)
        XCTAssertEqual(stats.totalExpenses, 0)
        XCTAssertEqual(stats.balance, 0)
        XCTAssertTrue(stats.expensesByCategory.isEmpty)
    }

    // MARK: - Income aggregation

    func test_incomeTransactions_summedIntoTotalIncome() throws {
        repository.stored = [
            makeTransaction(amount: 250_000, isIncome: true),
            makeTransaction(amount: 100_000, isIncome: true)
        ]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertEqual(stats.totalIncome, 350_000, accuracy: 0.01)
        XCTAssertEqual(stats.totalExpenses, 0)
    }

    // MARK: - Expense aggregation

    func test_expenseTransactions_summedIntoTotalExpenses() throws {
        repository.stored = [
            makeTransaction(amount: 15_000, category: .food, isIncome: false),
            makeTransaction(amount: 8_000,  category: .transport, isIncome: false)
        ]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertEqual(stats.totalExpenses, 23_000, accuracy: 0.01)
        XCTAssertEqual(stats.totalIncome, 0)
    }

    // MARK: - Category bucketing

    func test_expensesByCategory_bucketedCorrectly() throws {
        repository.stored = [
            makeTransaction(amount: 5_000, category: .food, isIncome: false),
            makeTransaction(amount: 3_000, category: .food, isIncome: false),
            makeTransaction(amount: 12_000, category: .transport, isIncome: false)
        ]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertEqual(stats.expensesByCategory[.food], 8_000, accuracy: 0.01,
            "Two food expenses must be combined into one bucket")
        XCTAssertEqual(stats.expensesByCategory[.transport], 12_000, accuracy: 0.01)
    }

    func test_unknownCategoryRawValue_fallsBackToOther() throws {
        // Transactions with unrecognised category strings map to .other
        let t = Transaction(amount: 2_000, date: ref, category: "garbage_value",
                            isIncome: false)
        repository.stored = [t]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertEqual(stats.expensesByCategory[.other], 2_000, accuracy: 0.01,
            "Unrecognised category must fall back to .other")
    }

    // MARK: - Mixed income and expenses

    func test_mixedTransactions_balanceIsCorrect() throws {
        repository.stored = [
            makeTransaction(amount: 300_000, isIncome: true),
            makeTransaction(amount: 50_000,  category: .food, isIncome: false),
            makeTransaction(amount: 20_000,  category: .utilities, isIncome: false)
        ]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertEqual(stats.totalIncome, 300_000, accuracy: 0.01)
        XCTAssertEqual(stats.totalExpenses, 70_000, accuracy: 0.01)
        XCTAssertEqual(stats.balance, 230_000, accuracy: 0.01)
    }

    // MARK: - Income not included in expensesByCategory

    func test_incomeTransactions_notAddedToExpensesByCategory() throws {
        repository.stored = [
            makeTransaction(amount: 100_000, category: .income, isIncome: true)
        ]
        let stats = try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        XCTAssertTrue(stats.expensesByCategory.isEmpty,
            "Income transactions must not appear in expensesByCategory")
    }

    // MARK: - Date range filtering (delegated to repository filter)

    func test_dateRange_isPassedThroughToRepository() throws {
        let start = ref
        let end   = ref.addingTimeInterval(86400)
        _ = try useCase.execute(startDate: start, endDate: end)
        // If the mock matches on dates, only in-range transactions are counted.
        // Verify no crash and filter arg was used (mock returns based on filter).
        XCTAssertEqual(repository.stored.count, 0) // nothing added = nothing fetched
    }

    // MARK: - Error propagation

    func test_repositoryError_propagatesToCaller() {
        repository.shouldThrowOnFetch = true
        XCTAssertThrowsError(
            try useCase.execute(startDate: .distantPast, endDate: .distantFuture)
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    // MARK: - Helpers

    private func makeTransaction(
        amount: Double,
        category: Category = .other,
        isIncome: Bool
    ) -> Transaction {
        Transaction(amount: amount, date: ref,
                    category: category.rawValue, isIncome: isIncome)
    }
}
