import Foundation
import SwiftData

@MainActor
final class DIContainer: ObservableObject {
    let modelContainer: ModelContainer

    // MARK: - Repositories

    lazy var transactionRepository: TransactionRepositoryProtocol = {
        SwiftDataTransactionRepository(modelContext: modelContainer.mainContext)
    }()

    lazy var categoryRuleRepository: CategoryRuleRepositoryProtocol = {
        SwiftDataCategoryRuleRepository(modelContext: modelContainer.mainContext)
    }()

    // MARK: - Services

    let categorizationEngine: CategorizationEngineProtocol = CategorizationEngine()
    let kaspiParser: StatementParserProtocol = KaspiStatementParser()

    // MARK: - Use Cases

    lazy var addTransactionUseCase: AddTransactionUseCase = {
        AddTransactionUseCase(repository: transactionRepository)
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

    // MARK: - Init

    init() {
        do {
            let schema = Schema([
                Transaction.self,
                CategoryRule.self
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
