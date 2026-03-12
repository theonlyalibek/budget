import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoryRuleRepository: CategoryRuleRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [CategoryRule] {
        let descriptor = FetchDescriptor<CategoryRule>(
            sortBy: [SortDescriptor(\.keyword)]
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ rule: CategoryRule) throws {
        modelContext.insert(rule)
        try modelContext.save()
    }

    func delete(_ rule: CategoryRule) throws {
        modelContext.delete(rule)
        try modelContext.save()
    }
}
