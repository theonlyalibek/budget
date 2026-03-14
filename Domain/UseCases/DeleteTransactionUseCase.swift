import Foundation

/// Deletes a single transaction.
@MainActor
final class DeleteTransactionUseCase {

    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ transaction: Transaction) throws {
        try repository.delete(transaction)
    }
}
