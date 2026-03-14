import Foundation
import SwiftData

@MainActor
final class SwiftDataCustomCategoryRepository: CustomCategoryRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Categories

    func fetchAll() throws -> [CustomCategory] {
        let descriptor = FetchDescriptor<CustomCategory>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchActive() throws -> [CustomCategory] {
        let predicate = #Predicate<CustomCategory> { $0.isActive }
        let descriptor = FetchDescriptor<CustomCategory>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    func add(_ category: CustomCategory) throws {
        modelContext.insert(category)
        try modelContext.save()
    }

    func update(_ category: CustomCategory) throws {
        try modelContext.save()
    }

    func delete(_ category: CustomCategory) throws {
        modelContext.delete(category)
        try modelContext.save()
    }

    // MARK: - Subcategories

    func addSubcategory(_ subcategory: CustomSubcategory) throws {
        modelContext.insert(subcategory)
        try modelContext.save()
    }

    func updateSubcategory(_ subcategory: CustomSubcategory) throws {
        try modelContext.save()
    }

    func deleteSubcategory(_ subcategory: CustomSubcategory) throws {
        modelContext.delete(subcategory)
        try modelContext.save()
    }
}
