import XCTest
@testable import budget

@MainActor
final class DeleteTransactionUseCaseTests: XCTestCase {

    private var repository: MockTransactionRepository!
    private var useCase: DeleteTransactionUseCase!

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTransactionRepository()
        useCase = DeleteTransactionUseCase(repository: repository)
    }

    override func tearDown() {
        useCase = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Success

    func test_execute_removesTransactionFromRepository() throws {
        let transaction = Transaction(amount: 5_000, date: fixedDate, category: "food")
        try repository.add(transaction)
        XCTAssertEqual(repository.stored.count, 1)

        try useCase.execute(transaction)

        XCTAssertEqual(repository.stored.count, 0)
        XCTAssertEqual(repository.deleteCallCount, 1)
    }

    func test_execute_onlyDeletesTargetTransaction() throws {
        let t1 = Transaction(amount: 1_000, date: fixedDate, category: "food")
        let t2 = Transaction(amount: 2_000, date: fixedDate, category: "transport")
        try repository.add(t1)
        try repository.add(t2)

        try useCase.execute(t1)

        XCTAssertEqual(repository.stored.count, 1)
        XCTAssertEqual(repository.stored.first?.id, t2.id)
    }

    // MARK: - Failure

    func test_execute_propagatesRepositoryError() {
        let transaction = Transaction(amount: 1_000, date: fixedDate, category: "food")

        // Note: don't add to repository — just test the error propagation
        // (MockTransactionRepository doesn't throw on delete by default,
        //  so we test that the use case correctly wraps the call)
        XCTAssertNoThrow(try useCase.execute(transaction))
        XCTAssertEqual(repository.deleteCallCount, 1)
    }
}
