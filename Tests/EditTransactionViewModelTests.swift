import XCTest
@testable import budget

@MainActor
final class EditTransactionViewModelTests: XCTestCase {

    private var repository: MockTransactionRepository!
    private var updateUseCase: UpdateTransactionUseCase!
    private var deleteUseCase: DeleteTransactionUseCase!

    private let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    override func setUp() {
        super.setUp()
        repository = MockTransactionRepository()
        updateUseCase = UpdateTransactionUseCase(repository: repository)
        deleteUseCase = DeleteTransactionUseCase(repository: repository)
    }

    override func tearDown() {
        deleteUseCase = nil
        updateUseCase = nil
        repository = nil
        super.tearDown()
    }

    private func makeTransaction(
        amount: Double = 5_000,
        category: String = "food",
        note: String = "Glovo",
        isSubscription: Bool = false,
        isIncome: Bool = false
    ) -> Transaction {
        Transaction(
            amount: amount,
            date: fixedDate,
            category: category,
            note: note,
            isSubscription: isSubscription,
            isIncome: isIncome
        )
    }

    private func makeVM(for transaction: Transaction) -> EditTransactionViewModel {
        EditTransactionViewModel(
            transaction: transaction,
            updateUseCase: updateUseCase,
            deleteUseCase: deleteUseCase
        )
    }

    // MARK: - Init populates form from transaction

    func test_init_populatesAmountText() {
        let vm = makeVM(for: makeTransaction(amount: 12_500))
        XCTAssertEqual(vm.amountText, "12500")
    }

    func test_init_populatesCategory() {
        let vm = makeVM(for: makeTransaction(category: "transport"))
        XCTAssertEqual(vm.category, .transport)
    }

    func test_init_populatesNote() {
        let vm = makeVM(for: makeTransaction(note: "Wolt"))
        XCTAssertEqual(vm.note, "Wolt")
    }

    func test_init_populatesIsSubscription() {
        let vm = makeVM(for: makeTransaction(isSubscription: true))
        XCTAssertTrue(vm.isSubscription)
    }

    func test_init_populatesIsIncome() {
        let vm = makeVM(for: makeTransaction(isIncome: true))
        XCTAssertTrue(vm.isIncome)
    }

    func test_init_unknownCategoryFallsBackToOther() {
        let t = Transaction(amount: 100, date: fixedDate, category: "nonexistent")
        let vm = makeVM(for: t)
        XCTAssertEqual(vm.category, .other)
    }

    // MARK: - hasChanges

    func test_hasChanges_falseWhenUnmodified() {
        let vm = makeVM(for: makeTransaction())
        XCTAssertFalse(vm.hasChanges)
    }

    func test_hasChanges_trueWhenAmountChanged() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "9999"
        XCTAssertTrue(vm.hasChanges)
    }

    func test_hasChanges_trueWhenCategoryChanged() {
        let vm = makeVM(for: makeTransaction())
        vm.category = .entertainment
        XCTAssertTrue(vm.hasChanges)
    }

    func test_hasChanges_trueWhenNoteChanged() {
        let vm = makeVM(for: makeTransaction())
        vm.note = "Changed"
        XCTAssertTrue(vm.hasChanges)
    }

    func test_hasChanges_trueWhenIsIncomeToggled() {
        let vm = makeVM(for: makeTransaction())
        vm.isIncome = true
        XCTAssertTrue(vm.hasChanges)
    }

    // MARK: - canSave

    func test_canSave_trueWhenAmountPositive() {
        let vm = makeVM(for: makeTransaction())
        XCTAssertTrue(vm.canSave)
    }

    func test_canSave_falseWhenAmountZero() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "0"
        XCTAssertFalse(vm.canSave)
    }

    func test_canSave_falseWhenAmountEmpty() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = ""
        XCTAssertFalse(vm.canSave)
    }

    // MARK: - parsedAmount locale handling

    func test_parsedAmount_handlesCommaDecimalSeparator() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "1500,50"
        XCTAssertEqual(vm.parsedAmount, 1500.50, accuracy: 0.01)
    }

    func test_parsedAmount_handlesDotDecimalSeparator() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "1500.50"
        XCTAssertEqual(vm.parsedAmount, 1500.50, accuracy: 0.01)
    }

    func test_parsedAmount_stripsSpaces() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "125 400"
        XCTAssertEqual(vm.parsedAmount, 125_400)
    }

    // MARK: - Save

    func test_save_updatesTransactionAndSetsDidSave() throws {
        let t = makeTransaction()
        try repository.add(t)
        let vm = makeVM(for: t)

        vm.amountText = "10000"
        vm.category = .transport
        vm.note = "Updated"
        vm.save()

        XCTAssertTrue(vm.didSave)
        XCTAssertEqual(t.amount, 10_000)
        XCTAssertEqual(t.category, "transport")
        XCTAssertEqual(t.note, "Updated")
        XCTAssertEqual(repository.updateCallCount, 1)
    }

    func test_save_doesNothingWhenAmountZero() {
        let vm = makeVM(for: makeTransaction())
        vm.amountText = "0"
        vm.save()

        XCTAssertFalse(vm.didSave)
        XCTAssertEqual(repository.updateCallCount, 0)
    }

    func test_save_setsErrorOnFailure() {
        let vm = makeVM(for: makeTransaction())
        repository.shouldThrowOnUpdate = true
        vm.amountText = "1000"
        vm.save()

        XCTAssertFalse(vm.didSave)
        XCTAssertNotNil(vm.errorMessage)
    }

    // MARK: - Delete

    func test_deleteTransaction_setsDidDelete() throws {
        let t = makeTransaction()
        try repository.add(t)
        let vm = makeVM(for: t)

        vm.deleteTransaction()

        XCTAssertTrue(vm.didDelete)
        XCTAssertEqual(repository.deleteCallCount, 1)
        XCTAssertEqual(repository.stored.count, 0)
    }

    func test_confirmDelete_showsConfirmation() {
        let vm = makeVM(for: makeTransaction())
        vm.confirmDelete()
        XCTAssertTrue(vm.showDeleteConfirmation)
    }
}
