import Foundation

/// Categorizes a transaction description into a Category
/// using keyword/regex rules.
protocol CategorizationEngineProtocol: Sendable {
    /// Categorize based on merchant/description string.
    func categorize(_ description: String) -> CategorizationResult

    /// Categorize using additional user-defined CategoryRule models.
    func categorize(_ description: String, userRules: [CategoryRule]) -> CategorizationResult
}
