import Foundation

/// Result of categorizing a transaction description.
struct CategorizationResult: Equatable, Sendable {
    let category: Category
    let subcategory: String
    let isSubscription: Bool

    static let unknown = CategorizationResult(
        category: .other,
        subcategory: "",
        isSubscription: false
    )
}
