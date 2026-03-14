import Foundation

/// Updates an existing transaction with new field values.
@MainActor
final class UpdateTransactionUseCase {

    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        _ transaction: Transaction,
        amount: Double,
        date: Date,
        categoryKey: String,
        subcategoryKey: String,
        note: String,
        isSubscription: Bool,
        isIncome: Bool
    ) throws {
        transaction.amount = amount
        transaction.date = date
        transaction.category = categoryKey
        transaction.subcategory = subcategoryKey
        transaction.note = note
        transaction.isSubscription = isSubscription
        transaction.isIncome = isIncome
        try repository.update(transaction)
    }
}
