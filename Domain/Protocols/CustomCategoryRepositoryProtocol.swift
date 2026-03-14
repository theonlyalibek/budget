import Foundation

/// Repository for custom user-defined categories and subcategories.
@MainActor
protocol CustomCategoryRepositoryProtocol {
    // MARK: - Categories
    func fetchAll() throws -> [CustomCategory]
    func fetchActive() throws -> [CustomCategory]
    func add(_ category: CustomCategory) throws
    func update(_ category: CustomCategory) throws
    func delete(_ category: CustomCategory) throws

    // MARK: - Subcategories
    func addSubcategory(_ subcategory: CustomSubcategory) throws
    func updateSubcategory(_ subcategory: CustomSubcategory) throws
    func deleteSubcategory(_ subcategory: CustomSubcategory) throws
}
