import Foundation
import Observation

@MainActor
@Observable
final class AddTransactionViewModel {

    // MARK: - Form State

    var amountText: String = ""
    var date: Date = .now
    var category: Category = .food
    var note: String = ""
    var isIncome: Bool = false

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

    // MARK: - Dependencies

    private let addTransactionUseCase: AddTransactionUseCase

    // MARK: - Init

    init(addTransactionUseCase: AddTransactionUseCase) {
        self.addTransactionUseCase = addTransactionUseCase
    }

    // MARK: - Actions

    func save() {
        guard canSave else { return }

        isSaving = true
        errorMessage = nil

        do {
            try addTransactionUseCase.execute(
                amount: parsedAmount,
                date: date,
                category: category,
                note: note,
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
        category = .food
        note = ""
        isIncome = false
    }
}
