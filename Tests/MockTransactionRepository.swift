import Foundation
@testable import budget

// MARK: - Test Error

enum TestError: LocalizedError {
    case intentional
    var errorDescription: String? { "Intentional test error" }
}

// MARK: - Mock Repository

/// In-memory `TransactionRepositoryProtocol` for unit testing.
/// No SwiftData or ModelContext required.
@MainActor
final class MockTransactionRepository: TransactionRepositoryProtocol {

    // MARK: - Recorded state

    private(set) var stored: [Transaction] = []
    private(set) var addCallCount = 0
    private(set) var addBatchCallCount = 0
    private(set) var deleteCallCount = 0
    private(set) var deleteAllCallCount = 0
    private(set) var lastAddedTransaction: Transaction?

    // MARK: - Test controls

    var shouldThrowOnFetch = false
    var shouldThrowOnAdd = false

    // MARK: - Protocol

    func fetch(filter: TransactionFilter) throws -> [Transaction] {
        if shouldThrowOnFetch { throw TestError.intentional }
        return stored
            .filter { matches($0, filter: filter) }
            .sorted { $0.date > $1.date }
    }

    func add(_ transaction: Transaction) throws {
        if shouldThrowOnAdd { throw TestError.intentional }
        addCallCount += 1
        lastAddedTransaction = transaction
        stored.append(transaction)
    }

    func addBatch(_ transactions: [Transaction]) throws {
        addBatchCallCount += 1
        stored.append(contentsOf: transactions)
    }

    func delete(_ transaction: Transaction) throws {
        deleteCallCount += 1
        stored.removeAll { $0.id == transaction.id }
    }

    func exists(date: Date, amount: Double, merchant: String) throws -> Bool {
        let cal = Calendar.current
        return stored.contains {
            cal.isDate($0.date, inSameDayAs: date)
                && $0.amount == amount
                && $0.note == merchant
        }
    }

    func deleteAll() throws {
        deleteAllCallCount += 1
        stored.removeAll()
    }

    // MARK: - Filter helper (mirrors SwiftDataTransactionRepository predicate logic)

    private func matches(_ t: Transaction, filter: TransactionFilter) -> Bool {
        if let start = filter.startDate, t.date < start { return false }
        if let end   = filter.endDate,   t.date > end   { return false }
        if let cat   = filter.category,  t.category != cat.rawValue { return false }
        if let inc   = filter.isIncome,  t.isIncome  != inc  { return false }
        if let sub   = filter.isSubscription, t.isSubscription != sub { return false }
        return true
    }
}
