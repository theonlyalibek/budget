import Foundation

// MARK: - Create Category

@MainActor
final class CreateCustomCategoryUseCase {
    private let repository: CustomCategoryRepositoryProtocol

    init(repository: CustomCategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, iconName: String, colorHex: String) throws -> CustomCategory {
        let category = CustomCategory(
            name: name,
            iconName: iconName,
            colorHex: colorHex
        )
        try repository.add(category)
        return category
    }
}

// MARK: - Update Category

@MainActor
final class UpdateCustomCategoryUseCase {
    private let repository: CustomCategoryRepositoryProtocol

    init(repository: CustomCategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        _ category: CustomCategory,
        name: String,
        iconName: String,
        colorHex: String,
        isActive: Bool
    ) throws {
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        category.isActive = isActive
        try repository.update(category)
    }
}

// MARK: - Delete Category

@MainActor
final class DeleteCustomCategoryUseCase {
    private let categoryRepository: CustomCategoryRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol

    init(
        categoryRepository: CustomCategoryRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol
    ) {
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository
    }

    /// Deletes a custom category and reassigns its transactions to "other".
    func execute(_ category: CustomCategory) throws {
        let storageKey = category.storageKey

        // Reassign orphaned transactions
        let allTransactions = try transactionRepository.fetch(filter: .all)
        for transaction in allTransactions where transaction.category == storageKey {
            transaction.category = Category.other.rawValue
            transaction.subcategory = ""
            try transactionRepository.update(transaction)
        }

        try categoryRepository.delete(category)
    }
}

// MARK: - Create Subcategory

@MainActor
final class CreateCustomSubcategoryUseCase {
    private let repository: CustomCategoryRepositoryProtocol

    init(repository: CustomCategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, parent: CustomCategory) throws -> CustomSubcategory {
        let subcategory = CustomSubcategory(
            name: name,
            parentCategory: parent
        )
        try repository.addSubcategory(subcategory)
        return subcategory
    }
}

// MARK: - Update Subcategory

@MainActor
final class UpdateCustomSubcategoryUseCase {
    private let repository: CustomCategoryRepositoryProtocol

    init(repository: CustomCategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ subcategory: CustomSubcategory, name: String, isActive: Bool) throws {
        subcategory.name = name
        subcategory.isActive = isActive
        try repository.updateSubcategory(subcategory)
    }
}

// MARK: - Delete Subcategory

@MainActor
final class DeleteCustomSubcategoryUseCase {
    private let categoryRepository: CustomCategoryRepositoryProtocol
    private let transactionRepository: TransactionRepositoryProtocol

    init(
        categoryRepository: CustomCategoryRepositoryProtocol,
        transactionRepository: TransactionRepositoryProtocol
    ) {
        self.categoryRepository = categoryRepository
        self.transactionRepository = transactionRepository
    }

    /// Deletes a subcategory and clears it from transactions.
    func execute(_ subcategory: CustomSubcategory) throws {
        let storageKey = subcategory.storageKey

        let allTransactions = try transactionRepository.fetch(filter: .all)
        for transaction in allTransactions where transaction.subcategory == storageKey {
            transaction.subcategory = ""
            try transactionRepository.update(transaction)
        }

        try categoryRepository.deleteSubcategory(subcategory)
    }
}
