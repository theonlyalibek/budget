import Foundation
import Observation

@MainActor
@Observable
final class CategoryDetailViewModel {

    // MARK: - State

    let category: Category
    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false

    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Dependencies

    private let repository: TransactionRepositoryProtocol

    // MARK: - Init

    init(category: Category, repository: TransactionRepositoryProtocol) {
        self.category = category
        self.repository = repository
    }

    // MARK: - Actions

    func load() {
        isLoading = true
        do {
            let filter = TransactionFilter(category: category, isIncome: false)
            transactions = try repository.fetch(filter: filter)
                .sorted { $0.date > $1.date }
        } catch {
            transactions = []
        }
        isLoading = false
    }
}
