import Foundation
import Observation

@MainActor
@Observable
final class CategoriesManagerViewModel {

    // MARK: - State

    private(set) var customCategories: [CustomCategory] = []
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    // Add/Edit Category
    var showAddCategory = false
    var editingCategory: CustomCategory?
    var categoryName = ""
    var categoryIcon = "folder.fill"
    var categoryColorHex = CategoryColorPreset.blue.rawValue

    // Add/Edit Subcategory
    var showAddSubcategory = false
    var addSubcategoryParent: CustomCategory?
    var editingSubcategory: CustomSubcategory?
    var subcategoryName = ""

    // Delete Confirmation
    var categoryToDelete: CustomCategory?
    var subcategoryToDelete: CustomSubcategory?

    // MARK: - Dependencies

    private let repository: CustomCategoryRepositoryProtocol
    private let createCategoryUseCase: CreateCustomCategoryUseCase
    private let updateCategoryUseCase: UpdateCustomCategoryUseCase
    private let deleteCategoryUseCase: DeleteCustomCategoryUseCase
    private let createSubcategoryUseCase: CreateCustomSubcategoryUseCase
    private let updateSubcategoryUseCase: UpdateCustomSubcategoryUseCase
    private let deleteSubcategoryUseCase: DeleteCustomSubcategoryUseCase

    // MARK: - Init

    init(
        repository: CustomCategoryRepositoryProtocol,
        createCategoryUseCase: CreateCustomCategoryUseCase,
        updateCategoryUseCase: UpdateCustomCategoryUseCase,
        deleteCategoryUseCase: DeleteCustomCategoryUseCase,
        createSubcategoryUseCase: CreateCustomSubcategoryUseCase,
        updateSubcategoryUseCase: UpdateCustomSubcategoryUseCase,
        deleteSubcategoryUseCase: DeleteCustomSubcategoryUseCase
    ) {
        self.repository = repository
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
        self.createSubcategoryUseCase = createSubcategoryUseCase
        self.updateSubcategoryUseCase = updateSubcategoryUseCase
        self.deleteSubcategoryUseCase = deleteSubcategoryUseCase
    }

    // MARK: - Load

    func loadCategories() {
        isLoading = true
        errorMessage = nil
        do {
            customCategories = try repository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Category CRUD

    func prepareAddCategory() {
        editingCategory = nil
        categoryName = ""
        categoryIcon = "folder.fill"
        categoryColorHex = CategoryColorPreset.blue.rawValue
        showAddCategory = true
    }

    func prepareEditCategory(_ category: CustomCategory) {
        editingCategory = category
        categoryName = category.name
        categoryIcon = category.iconName
        categoryColorHex = category.colorHex
        showAddCategory = true
    }

    func saveCategory() {
        guard !categoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        errorMessage = nil
        do {
            if let existing = editingCategory {
                try updateCategoryUseCase.execute(
                    existing,
                    name: categoryName.trimmingCharacters(in: .whitespaces),
                    iconName: categoryIcon,
                    colorHex: categoryColorHex,
                    isActive: existing.isActive
                )
            } else {
                _ = try createCategoryUseCase.execute(
                    name: categoryName.trimmingCharacters(in: .whitespaces),
                    iconName: categoryIcon,
                    colorHex: categoryColorHex
                )
            }
            showAddCategory = false
            loadCategories()
            notifyCategoriesChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmDeleteCategory(_ category: CustomCategory) {
        categoryToDelete = category
    }

    func deleteCategory() {
        guard let category = categoryToDelete else { return }
        errorMessage = nil
        do {
            try deleteCategoryUseCase.execute(category)
            categoryToDelete = nil
            loadCategories()
            notifyCategoriesChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCategoryActive(_ category: CustomCategory) {
        errorMessage = nil
        do {
            try updateCategoryUseCase.execute(
                category,
                name: category.name,
                iconName: category.iconName,
                colorHex: category.colorHex,
                isActive: !category.isActive
            )
            loadCategories()
            notifyCategoriesChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Subcategory CRUD

    func prepareAddSubcategory(parent: CustomCategory) {
        editingSubcategory = nil
        addSubcategoryParent = parent
        subcategoryName = ""
        showAddSubcategory = true
    }

    func prepareEditSubcategory(_ subcategory: CustomSubcategory) {
        editingSubcategory = subcategory
        subcategoryName = subcategory.name
        showAddSubcategory = true
    }

    func saveSubcategory() {
        guard !subcategoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        errorMessage = nil
        do {
            if let existing = editingSubcategory {
                try updateSubcategoryUseCase.execute(
                    existing,
                    name: subcategoryName.trimmingCharacters(in: .whitespaces),
                    isActive: existing.isActive
                )
            } else if let parent = addSubcategoryParent {
                _ = try createSubcategoryUseCase.execute(
                    name: subcategoryName.trimmingCharacters(in: .whitespaces),
                    parent: parent
                )
            }
            showAddSubcategory = false
            loadCategories()
            notifyCategoriesChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmDeleteSubcategory(_ subcategory: CustomSubcategory) {
        subcategoryToDelete = subcategory
    }

    func deleteSubcategory() {
        guard let subcategory = subcategoryToDelete else { return }
        errorMessage = nil
        do {
            try deleteSubcategoryUseCase.execute(subcategory)
            subcategoryToDelete = nil
            loadCategories()
            notifyCategoriesChanged()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Notification

    private func notifyCategoriesChanged() {
        NotificationCenter.default.post(name: .customCategoriesDidChange, object: nil)
    }
}
