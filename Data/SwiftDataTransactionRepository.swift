import Foundation
import SwiftData

@MainActor
final class SwiftDataTransactionRepository: TransactionRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetch

    func fetch(filter: TransactionFilter) throws -> [Transaction] {
        var predicates: [Predicate<Transaction>] = []

        if let startDate = filter.startDate {
            predicates.append(#Predicate<Transaction> { $0.date >= startDate })
        }
        if let endDate = filter.endDate {
            predicates.append(#Predicate<Transaction> { $0.date <= endDate })
        }
        if let categoryRaw = filter.categoryRaw {
            predicates.append(#Predicate<Transaction> { $0.category == categoryRaw })
        }
        if let isIncome = filter.isIncome {
            predicates.append(#Predicate<Transaction> { $0.isIncome == isIncome })
        }
        if let isSubscription = filter.isSubscription {
            predicates.append(#Predicate<Transaction> { $0.isSubscription == isSubscription })
        }

        let combined = combinedPredicate(from: predicates)

        var descriptor = FetchDescriptor<Transaction>(
            predicate: combined,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = nil

        return try modelContext.fetch(descriptor)
    }

    // MARK: - Add

    func add(_ transaction: Transaction) throws {
        modelContext.insert(transaction)
        try modelContext.save()
    }

    func addBatch(_ transactions: [Transaction]) throws {
        for transaction in transactions {
            modelContext.insert(transaction)
        }
        try modelContext.save()
    }

    // MARK: - Update

    func update(_ transaction: Transaction) throws {
        // SwiftData tracks changes to @Model objects automatically;
        // we just need to persist to disk.
        try modelContext.save()
    }

    // MARK: - Delete

    func delete(_ transaction: Transaction) throws {
        modelContext.delete(transaction)
        try modelContext.save()
    }

    func deleteAll() throws {
        let all = try modelContext.fetch(FetchDescriptor<Transaction>())
        for transaction in all {
            modelContext.delete(transaction)
        }
        try modelContext.save()
    }

    // MARK: - Duplicate Check

    func exists(date: Date, amount: Double, merchant: String) throws -> Bool {
        // Match on same calendar day (ignoring time), same amount, same note (merchant).
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }

        let predicate = #Predicate<Transaction> {
            $0.date >= startOfDay &&
            $0.date < endOfDay &&
            $0.amount == amount &&
            $0.note == merchant
        }

        var descriptor = FetchDescriptor<Transaction>(predicate: predicate)
        descriptor.fetchLimit = 1

        let results = try modelContext.fetch(descriptor)
        return !results.isEmpty
    }

    // MARK: - Predicate Helpers

    /// Combines an array of predicates with logical AND.
    /// Returns nil (match all) if the array is empty.
    private func combinedPredicate(
        from predicates: [Predicate<Transaction>]
    ) -> Predicate<Transaction>? {
        guard !predicates.isEmpty else { return nil }

        // SwiftData doesn't support dynamic predicate composition natively,
        // so we build the combined predicate step by step.
        var result = predicates[0]
        for i in 1..<predicates.count {
            let next = predicates[i]
            let current = result
            result = #Predicate<Transaction> { transaction in
                current.evaluate(transaction) && next.evaluate(transaction)
            }
        }
        return result
    }
}
