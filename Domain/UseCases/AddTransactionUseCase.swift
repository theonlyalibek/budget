import Foundation

/// Adds a single manually-entered transaction.
@MainActor
final class AddTransactionUseCase {

    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        amount: Double,
        date: Date,
        category: Category,
        subcategory: String = "",
        note: String = "",
        isSubscription: Bool = false,
        isIncome: Bool = false
    ) throws {
        let transaction = Transaction(
            amount: amount,
            date: date,
            category: category.rawValue,
            subcategory: subcategory,
            note: note,
            isSubscription: isSubscription,
            isIncome: isIncome
        )
        try repository.add(transaction)
    }
}
