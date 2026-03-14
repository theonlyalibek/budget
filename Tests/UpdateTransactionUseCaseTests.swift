import XCTest
@testable import budget

@MainActor
final class UpdateTransactionUseCaseTests: XCTestCase {

    private var repository: MockTransactionRepository!
    private var useCase: UpdateTransactionUseCase!

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTransactionRepository()
        useCase = UpdateTransactionUseCase(repository: repository)
    }

    override func tearDown() {
        useCase = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_execute_updatesAllFields() throws {
        let transaction = Transaction(
            amount: 5_000,
            date: fixedDate,
            category: "food",
            note: "Old note",
            isSubscription: false,
            isIncome: false
        )
        try repository.add(transaction)

        let newDate = Date(timeIntervalSince1970: 1_700_100_000)
        try useCase.execute(
            transaction,
            amount: 12_000,
            date: newDate,
            categoryKey: "transport",
            subcategoryKey: "taxi",
            note: "New note",
            isSubscription: true,
            isIncome: true
        )

        XCTAssertEqual(transaction.amount, 12_000)
        XCTAssertEqual(transaction.date, newDate)
        XCTAssertEqual(transaction.category, "transport")
        XCTAssertEqual(transaction.subcategory, "taxi")
        XCTAssertEqual(transaction.note, "New note")
        XCTAssertTrue(transaction.isSubscription)
        XCTAssertTrue(transaction.isIncome)
    }

    func test_execute_callsRepositoryUpdateOnce() throws {
        let transaction = Transaction(amount: 1_000, date: fixedDate, category: "food")
        try repository.add(transaction)

        try useCase.execute(
            transaction,
            amount: 2_000,
            date: fixedDate,
            categoryKey: "food",
            subcategoryKey: "",
            note: "",
            isSubscription: false,
            isIncome: false
        )

        XCTAssertEqual(repository.updateCallCount, 1)
        XCTAssertIdentical(repository.lastUpdatedTransaction, transaction)
    }

    // MARK: - Failure

    func test_execute_throwsWhenRepositoryFails() {
        let transaction = Transaction(amount: 1_000, date: fixedDate, category: "food")

        repository.shouldThrowOnUpdate = true

        XCTAssertThrowsError(
            try useCase.execute(
                transaction,
                amount: 2_000,
                date: fixedDate,
                categoryKey: "food",
                subcategoryKey: "",
                note: "",
                isSubscription: false,
                isIncome: false
            )
        )
    }

    func test_execute_mutatesFieldsEvenOnFailure() {
        // SwiftData pattern: fields are mutated first, then save may fail.
        // This matches real SwiftData behavior where ModelContext rollback is separate.
        let transaction = Transaction(amount: 1_000, date: fixedDate, category: "food")

        repository.shouldThrowOnUpdate = true

        try? useCase.execute(
            transaction,
            amount: 9_999,
            date: fixedDate,
            categoryKey: "entertainment",
            subcategoryKey: "",
            note: "changed",
            isSubscription: false,
            isIncome: false
        )

        // Fields were mutated before the save call
        XCTAssertEqual(transaction.amount, 9_999)
        XCTAssertEqual(transaction.category, "entertainment")
        XCTAssertEqual(transaction.note, "changed")
    }
}
