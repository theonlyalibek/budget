import Foundation

/// Result of an import operation, returned before saving
/// so the user can preview and edit categories.
struct ImportResult: Sendable {
    let transactions: [ImportedTransaction]
    let duplicatesSkipped: Int
}

/// A single parsed + categorized transaction ready for review.
/// Mutable category/subcategory so the user can override before saving.
struct ImportedTransaction: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let amount: Double
    let merchant: String
    let isIncome: Bool
    var category: Category
    var subcategory: String
    var isSubscription: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        amount: Double,
        merchant: String,
        isIncome: Bool,
        category: Category,
        subcategory: String,
        isSubscription: Bool
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.merchant = merchant
        self.isIncome = isIncome
        self.category = category
        self.subcategory = subcategory
        self.isSubscription = isSubscription
    }
}
