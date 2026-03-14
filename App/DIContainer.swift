import Foundation
import SwiftData

@MainActor
final class DIContainer: ObservableObject {
    let modelContainer: ModelContainer

    // MARK: - Subscription

    /// Shared subscription service — injected into SwiftUI environment via BudgetApp.
    /// To add StoreKit2: create `StoreKitSubscriptionService: SubscriptionServiceProtocol`
    /// and replace `LocalSubscriptionService()` here. No view code changes required.
    let subscriptionService = LocalSubscriptionService()

    // MARK: - Repositories

    lazy var transactionRepository: TransactionRepositoryProtocol = {
        SwiftDataTransactionRepository(modelContext: modelContainer.mainContext)
    }()

    lazy var categoryRuleRepository: CategoryRuleRepositoryProtocol = {
        SwiftDataCategoryRuleRepository(modelContext: modelContainer.mainContext)
    }()

    lazy var customCategoryRepository: CustomCategoryRepositoryProtocol = {
        SwiftDataCustomCategoryRepository(modelContext: modelContainer.mainContext)
    }()

    // MARK: - Services

    let categorizationEngine: CategorizationEngineProtocol = CategorizationEngine()
    let kaspiParser: StatementParserProtocol = KaspiStatementParser()

    // MARK: - Use Cases — Transactions

    lazy var addTransactionUseCase: AddTransactionUseCase = {
        AddTransactionUseCase(repository: transactionRepository)
    }()

    lazy var updateTransactionUseCase: UpdateTransactionUseCase = {
        UpdateTransactionUseCase(repository: transactionRepository)
    }()

    lazy var deleteTransactionUseCase: DeleteTransactionUseCase = {
        DeleteTransactionUseCase(repository: transactionRepository)
    }()

    lazy var importStatementUseCase: ImportStatementUseCase = {
        ImportStatementUseCase(
            transactionRepository: transactionRepository,
            categoryRuleRepository: categoryRuleRepository,
            categorizationEngine: categorizationEngine
        )
    }()

    lazy var getDashboardStatsUseCase: GetDashboardStatsUseCase = {
        GetDashboardStatsUseCase(repository: transactionRepository)
    }()

    // MARK: - Use Cases — Custom Categories

    lazy var createCustomCategoryUseCase: CreateCustomCategoryUseCase = {
        CreateCustomCategoryUseCase(repository: customCategoryRepository)
    }()

    lazy var updateCustomCategoryUseCase: UpdateCustomCategoryUseCase = {
        UpdateCustomCategoryUseCase(repository: customCategoryRepository)
    }()

    lazy var deleteCustomCategoryUseCase: DeleteCustomCategoryUseCase = {
        DeleteCustomCategoryUseCase(
            categoryRepository: customCategoryRepository,
            transactionRepository: transactionRepository
        )
    }()

    lazy var createCustomSubcategoryUseCase: CreateCustomSubcategoryUseCase = {
        CreateCustomSubcategoryUseCase(repository: customCategoryRepository)
    }()

    lazy var updateCustomSubcategoryUseCase: UpdateCustomSubcategoryUseCase = {
        UpdateCustomSubcategoryUseCase(repository: customCategoryRepository)
    }()

    lazy var deleteCustomSubcategoryUseCase: DeleteCustomSubcategoryUseCase = {
        DeleteCustomSubcategoryUseCase(
            categoryRepository: customCategoryRepository,
            transactionRepository: transactionRepository
        )
    }()

    // MARK: - Custom Category Helpers

    /// Fetches active custom categories as value-type snapshots for use in views.
    func loadCustomCategorySnapshots() -> [CustomCategorySnapshot] {
        do {
            let categories = try customCategoryRepository.fetchActive()
            return categories.map { $0.snapshot }
        } catch {
            return []
        }
    }

    // MARK: - Init

    init() {
        do {
            let schema = Schema([
                Transaction.self,
                CategoryRule.self,
                CustomCategory.self,
                CustomSubcategory.self
            ])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
}
