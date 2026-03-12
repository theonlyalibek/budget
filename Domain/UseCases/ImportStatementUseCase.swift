import Foundation

/// Orchestrates PDF text parsing → categorization → duplicate filtering → saving.
///
/// Flow:
///   1. `preview(text:parser:)` — parse + categorize, return preview for user editing
///   2. User reviews / edits categories in the UI
///   3. `save(transactions:)` — persist the approved transactions
@MainActor
final class ImportStatementUseCase {

    private let transactionRepository: TransactionRepositoryProtocol
    private let categoryRuleRepository: CategoryRuleRepositoryProtocol
    private let categorizationEngine: CategorizationEngineProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        categoryRuleRepository: CategoryRuleRepositoryProtocol,
        categorizationEngine: CategorizationEngineProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.categoryRuleRepository = categoryRuleRepository
        self.categorizationEngine = categorizationEngine
    }

    // MARK: - Step 1: Preview

    /// Parse raw PDF text and return categorized transactions for user review.
    /// Duplicates are already filtered out.
    func preview(
        text: String,
        parser: StatementParserProtocol
    ) throws -> ImportResult {
        // Parse raw text
        let parsed: [ParsedTransaction]
        switch parser.parse(text) {
        case .success(let result):
            parsed = result
        case .failure(let error):
            throw error
        }

        // Load user rules for categorization
        let userRules = (try? categoryRuleRepository.fetchAll()) ?? []

        // Categorize and filter duplicates
        var imported: [ImportedTransaction] = []
        var duplicatesSkipped = 0

        for item in parsed {
            // Check for duplicates
            let isDuplicate = (try? transactionRepository.exists(
                date: item.date,
                amount: item.amount,
                merchant: item.merchant
            )) ?? false

            if isDuplicate {
                duplicatesSkipped += 1
                continue
            }

            // Categorize
            let result = categorizationEngine.categorize(
                item.merchant,
                userRules: userRules
            )

            imported.append(ImportedTransaction(
                date: item.date,
                amount: item.amount,
                merchant: item.merchant,
                isIncome: item.isIncome,
                category: result.category,
                subcategory: result.subcategory,
                isSubscription: result.isSubscription
            ))
        }

        return ImportResult(
            transactions: imported,
            duplicatesSkipped: duplicatesSkipped
        )
    }

    // MARK: - Step 2: Save

    /// Persist the user-approved transactions to SwiftData.
    func save(transactions: [ImportedTransaction]) throws {
        let models = transactions.map { item in
            Transaction(
                amount: item.amount,
                date: item.date,
                category: item.category.rawValue,
                subcategory: item.subcategory,
                note: item.merchant,
                isSubscription: item.isSubscription,
                isIncome: item.isIncome
            )
        }
        try transactionRepository.addBatch(models)
    }
}
