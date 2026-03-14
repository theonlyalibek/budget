import Foundation
import Observation

@MainActor
@Observable
final class CategoryDetailViewModel {

    // MARK: - State

    let categoryItem: CategoryItem
    private(set) var transactions: [Transaction] = []
    private(set) var isLoading = false

    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Dependencies

    private let repository: TransactionRepositoryProtocol

    // MARK: - Init

    init(
        categoryKey: String,
        customCategories: [CustomCategorySnapshot],
        repository: TransactionRepositoryProtocol
    ) {
        self.categoryItem = CategoryItem.from(
            storedValue: categoryKey,
            customCategories: customCategories
        )
        self.repository = repository
    }

    // MARK: - Actions

    func load() {
        isLoading = true
        do {
            let filter = TransactionFilter(
                categoryRaw: categoryItem.storageKey,
                isIncome: false
            )
            transactions = try repository.fetch(filter: filter)
                .sorted { $0.date > $1.date }
        } catch {
            transactions = []
        }
        isLoading = false
    }
}
