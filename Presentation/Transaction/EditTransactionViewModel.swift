import Foundation
import Observation

@MainActor
@Observable
final class EditTransactionViewModel {

    // MARK: - Source

    let transaction: Transaction

    // MARK: - Form State (copied from transaction for cancel-safe editing)

    var amountText: String
    var date: Date
    var selectedCategory: CategoryItem
    var selectedSubcategory: SubcategoryItem?
    var note: String
    var isIncome: Bool
    var isSubscription: Bool

    // MARK: - Taxonomy

    let allCategories: [CategoryItem]
    private let customSnapshots: [CustomCategorySnapshot]

    // MARK: - UI State

    private(set) var isSaving = false
    private(set) var isDeleting = false
    private(set) var errorMessage: String?
    var didSave = false
    var didDelete = false
    var showDeleteConfirmation = false

    // MARK: - Computed

    var parsedAmount: Double {
        let cleaned = amountText
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned) ?? 0
    }

    var canSave: Bool {
        parsedAmount > 0 && !isSaving && !isDeleting
    }

    var hasChanges: Bool {
        parsedAmount != transaction.amount
            || date != transaction.date
            || selectedCategory.storageKey != transaction.category
            || (selectedSubcategory?.storageKey ?? "") != transaction.subcategory
            || note != transaction.note
            || isIncome != transaction.isIncome
            || isSubscription != transaction.isSubscription
    }

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

    private let updateUseCase: UpdateTransactionUseCase
    private let deleteUseCase: DeleteTransactionUseCase

    // MARK: - Init

    init(
        transaction: Transaction,
        updateUseCase: UpdateTransactionUseCase,
        deleteUseCase: DeleteTransactionUseCase,
        customCategories: [CustomCategorySnapshot] = []
    ) {
        self.transaction = transaction
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.customSnapshots = customCategories

        var items: [CategoryItem] = Category.allCases.map { .system($0) }
        items.append(contentsOf: customCategories.map { .custom($0) })
        self.allCategories = items

        // Populate form from existing transaction
        self.amountText = CurrencyFormatter.formatRaw(transaction.amount)
        self.date = transaction.date
        self.selectedCategory = CategoryItem.from(
            storedValue: transaction.category,
            customCategories: customCategories
        )
        // Resolve subcategory
        let subKey = transaction.subcategory
        if !subKey.isEmpty {
            let catItem = CategoryItem.from(
                storedValue: transaction.category,
                customCategories: customCategories
            )
            self.selectedSubcategory = catItem.subcategoryItems.first { $0.storageKey == subKey }
        } else {
            self.selectedSubcategory = nil
        }
        self.note = transaction.note
        self.isIncome = transaction.isIncome
        self.isSubscription = transaction.isSubscription
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
            try updateUseCase.execute(
                transaction,
                amount: parsedAmount,
                date: date,
                categoryKey: selectedCategory.storageKey,
                subcategoryKey: selectedSubcategory?.storageKey ?? "",
                note: note,
                isSubscription: isSubscription,
                isIncome: isIncome
            )
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
    }

    func confirmDelete() {
        showDeleteConfirmation = true
    }

    func deleteTransaction() {
        isDeleting = true
        errorMessage = nil

        do {
            try deleteUseCase.execute(transaction)
            didDelete = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isDeleting = false
    }
}
