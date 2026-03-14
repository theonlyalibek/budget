import Foundation
import Observation

@MainActor
@Observable
final class AddTransactionViewModel {

    // MARK: - Form State

    var amountText: String = ""
    var date: Date = .now
    var selectedCategory: CategoryItem = .system(.food)
    var selectedSubcategory: SubcategoryItem?
    var note: String = ""
    var isIncome: Bool = false
    var isSubscription: Bool = false

    // MARK: - Taxonomy

    /// All available categories (system + custom), set on init.
    let allCategories: [CategoryItem]

    // MARK: - UI State

    private(set) var isSaving = false
    private(set) var errorMessage: String?
    var didSave = false

    // MARK: - Computed

    var parsedAmount: Double {
        let cleaned = amountText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0
    }

    var canSave: Bool {
        parsedAmount > 0 && !isSaving
    }

    /// Categories for the grid (exclude income/transfers for system categories).
    var expenseCategories: [CategoryItem] {
        allCategories.filter { item in
            switch item {
            case .system(let cat):
                cat != .income && cat != .transfers
            case .custom:
                true
            }
        }
    }

    // MARK: - Dependencies

    private let addTransactionUseCase: AddTransactionUseCase

    // MARK: - Init

    init(
        addTransactionUseCase: AddTransactionUseCase,
        customCategories: [CustomCategorySnapshot] = []
    ) {
        self.addTransactionUseCase = addTransactionUseCase

        var items: [CategoryItem] = Category.allCases.map { .system($0) }
        items.append(contentsOf: customCategories.map { .custom($0) })
        self.allCategories = items
    }

    // MARK: - Actions

    func selectCategory(_ item: CategoryItem) {
        if selectedCategory != item {
            selectedCategory = item
            selectedSubcategory = nil
        }
    }

    func toggleSubcategory(_ item: SubcategoryItem) {
        if selectedSubcategory == item {
            selectedSubcategory = nil
        } else {
            selectedSubcategory = item
        }
    }

    func save() {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        do {
            try addTransactionUseCase.execute(
                amount: parsedAmount,
                date: date,
                categoryKey: selectedCategory.storageKey,
                subcategoryKey: selectedSubcategory?.storageKey ?? "",
                note: note,
                isSubscription: isSubscription,
                isIncome: isIncome
            )
            didSave = true
            resetForm()
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    private func resetForm() {
        amountText = ""
        date = .now
        selectedCategory = .system(.food)
        selectedSubcategory = nil
        note = ""
        isIncome = false
        isSubscription = false
    }
}
