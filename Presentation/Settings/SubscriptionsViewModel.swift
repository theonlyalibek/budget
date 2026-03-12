import Foundation
import Observation

/// Groups subscription transactions by merchant name.
struct SubscriptionItem: Identifiable {
    let id: String          // merchant name as ID
    let merchant: String
    let category: Category
    let lastAmount: Double
    let lastDate: Date
    let occurrences: Int
}

@MainActor
@Observable
final class SubscriptionsViewModel {

    // MARK: - State

    private(set) var subscriptions: [SubscriptionItem] = []
    private(set) var isLoading = false

    // MARK: - Computed

    var totalMonthly: Double {
        subscriptions.reduce(0) { $0 + $1.lastAmount }
    }

    var isEmpty: Bool { subscriptions.isEmpty }

    // MARK: - Dependencies

    private let repository: TransactionRepositoryProtocol

    // MARK: - Init

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    func load() {
        isLoading = true
        defer { isLoading = false }

        do {
            let all = try repository.fetch(filter: .subscriptions)
            subscriptions = groupByMerchant(all)
        } catch {
            subscriptions = []
        }
    }

    // MARK: - Grouping

    /// Groups transactions by merchant (note field), keeping the most recent of each.
    private func groupByMerchant(_ transactions: [Transaction]) -> [SubscriptionItem] {
        let grouped = Dictionary(grouping: transactions) { $0.note.lowercased() }

        return grouped.compactMap { (_, items) in
            // Sort by date descending, take the latest
            let sorted = items.sorted { $0.date > $1.date }
            guard let latest = sorted.first else { return nil }

            return SubscriptionItem(
                id: latest.note.lowercased(),
                merchant: latest.note,
                category: Category(rawValue: latest.category) ?? .subscriptions,
                lastAmount: latest.amount,
                lastDate: latest.date,
                occurrences: items.count
            )
        }
        .sorted { $0.lastAmount > $1.lastAmount }
    }
}
