import Foundation

/// Filter criteria for fetching transactions.
struct TransactionFilter: Sendable {
    var startDate: Date?
    var endDate: Date?
    /// Raw category string (enum rawValue or "custom:<UUID>").
    var categoryRaw: String?
    var isIncome: Bool?
    var isSubscription: Bool?

    init(
        startDate: Date? = nil,
        endDate: Date? = nil,
        categoryRaw: String? = nil,
        isIncome: Bool? = nil,
        isSubscription: Bool? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.categoryRaw = categoryRaw
        self.isIncome = isIncome
        self.isSubscription = isSubscription
    }

    static let all = TransactionFilter()
    static let subscriptions = TransactionFilter(isSubscription: true)
}

/// Repository for persisting and querying Transaction models.
@MainActor
protocol TransactionRepositoryProtocol {
    /// Fetch transactions matching the given filter, ordered by date descending.
    func fetch(filter: TransactionFilter) throws -> [Transaction]

    /// Add a single transaction.
    func add(_ transaction: Transaction) throws

    /// Add multiple transactions in a batch (e.g. from PDF import).
    func addBatch(_ transactions: [Transaction]) throws

    /// Persist in-memory changes to an existing transaction.
    func update(_ transaction: Transaction) throws

    /// Delete a transaction by reference.
    func delete(_ transaction: Transaction) throws

    /// Check if a transaction with matching date, amount, and merchant already exists.
    func exists(date: Date, amount: Double, merchant: String) throws -> Bool

    /// Delete all transactions. Used for data reset.
    func deleteAll() throws
}
