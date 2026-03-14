import XCTest
@testable import budget

@MainActor
final class AddTransactionUseCaseTests: XCTestCase {

    private var repository: MockTransactionRepository!
    private var useCase: AddTransactionUseCase!

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTransactionRepository()
        useCase = AddTransactionUseCase(repository: repository)
    }

    override func tearDown() {
        useCase = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Core save behaviour

    func test_execute_callsRepositoryAddOnce() throws {
        try useCase.execute(amount: 5_000, date: fixedDate, category: .food)
        XCTAssertEqual(repository.addCallCount, 1,
            "execute must call repository.add exactly once")
    }

    func test_execute_savesCorrectAmount() throws {
        try useCase.execute(amount: 12_500, date: fixedDate, category: .transport)
        XCTAssertEqual(repository.lastAddedTransaction?.amount, 12_500, accuracy: 0.01)
    }

    func test_execute_savesCorrectDate() throws {
        try useCase.execute(amount: 1_000, date: fixedDate, category: .food)
        XCTAssertEqual(repository.lastAddedTransaction?.date, fixedDate)
    }

    // MARK: - Category mapping

    func test_execute_storesCategoryRawValue() throws {
        try useCase.execute(amount: 500, date: fixedDate, category: .entertainment)
        XCTAssertEqual(repository.lastAddedTransaction?.category, Category.entertainment.rawValue,
            "UseCase must store category.rawValue, not the enum itself")
    }

    func test_execute_allCategories_storedCorrectly() throws {
        for cat in Category.allCases {
            try useCase.execute(amount: 100, date: fixedDate, category: cat)
        }
        let stored = repository.stored.map(\.category)
        let expected = Category.allCases.map(\.rawValue)
        XCTAssertEqual(stored, expected)
    }

    // MARK: - Flag preservation

    func test_execute_isIncomeTrue_preserved() throws {
        try useCase.execute(amount: 300_000, date: fixedDate, category: .income, isIncome: true)
        XCTAssertTrue(repository.lastAddedTransaction?.isIncome ?? false)
    }

    func test_execute_isIncomeFalse_preserved() throws {
        try useCase.execute(amount: 5_000, date: fixedDate, category: .food, isIncome: false)
        XCTAssertFalse(repository.lastAddedTransaction?.isIncome ?? true)
    }

    func test_execute_isSubscriptionTrue_preserved() throws {
        try useCase.execute(amount: 2_990, date: fixedDate, category: .subscriptions,
                            isSubscription: true)
        XCTAssertTrue(repository.lastAddedTransaction?.isSubscription ?? false,
            "isSubscription=true must be stored on the Transaction")
    }

    func test_execute_isSubscriptionFalse_default_preserved() throws {
        try useCase.execute(amount: 500, date: fixedDate, category: .food)
        XCTAssertFalse(repository.lastAddedTransaction?.isSubscription ?? true,
            "isSubscription must default to false")
    }

    // MARK: - Note / subcategory

    func test_execute_notePreserved() throws {
        try useCase.execute(amount: 1_000, date: fixedDate, category: .food, note: "Обед")
        XCTAssertEqual(repository.lastAddedTransaction?.note, "Обед")
    }

    func test_execute_emptyNote_default() throws {
        try useCase.execute(amount: 1_000, date: fixedDate, category: .food)
        XCTAssertEqual(repository.lastAddedTransaction?.note, "")
    }

    func test_execute_subcategoryPreserved() throws {
        try useCase.execute(amount: 500, date: fixedDate, category: .food,
                            subcategory: "Кафе")
        XCTAssertEqual(repository.lastAddedTransaction?.subcategory, "Кафе")
    }

    // MARK: - Error propagation

    func test_execute_repositoryThrows_errorPropagated() {
        repository.shouldThrowOnAdd = true
        XCTAssertThrowsError(
            try useCase.execute(amount: 500, date: fixedDate, category: .food)
        ) { error in
            XCTAssertTrue(error is TestError,
                "UseCase must re-throw repository errors, not swallow them")
        }
    }

    func test_execute_repositoryThrows_nothingStored() {
        repository.shouldThrowOnAdd = true
        try? useCase.execute(amount: 500, date: fixedDate, category: .food)
        XCTAssertTrue(repository.stored.isEmpty,
            "Failed add must not leave a partial transaction in the repository")
    }

    // MARK: - Multiple calls

    func test_execute_multipleCalls_allPersisted() throws {
        try useCase.execute(amount: 100, date: fixedDate, category: .food)
        try useCase.execute(amount: 200, date: fixedDate, category: .transport)
        try useCase.execute(amount: 300, date: fixedDate, category: .health)
        XCTAssertEqual(repository.stored.count, 3)
        XCTAssertEqual(repository.addCallCount, 3)
    }
}
