import Foundation
import Observation

@MainActor
@Observable
final class ImportViewModel {

    // MARK: - State

    var previewTransactions: [ImportedTransaction] = []
    private(set) var duplicatesSkipped: Int = 0
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var didSave = false

    // MARK: - Dependencies

    private let importUseCase: ImportStatementUseCase
    private let parser: StatementParserProtocol

    // MARK: - Init

    init(
        importUseCase: ImportStatementUseCase,
        parser: StatementParserProtocol
    ) {
        self.importUseCase = importUseCase
        self.parser = parser
    }

    // MARK: - Computed

    var hasPreview: Bool { !previewTransactions.isEmpty }
    var transactionCount: Int { previewTransactions.count }

    var previewTotal: Double {
        previewTransactions
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }

    // MARK: - Actions

    /// Read PDF at url, parse, categorize, and populate preview.
    func handleFile(at url: URL) {
        isLoading = true
        errorMessage = nil
        previewTransactions = []
        duplicatesSkipped = 0

        defer { isLoading = false }

        // Gain security-scoped access for files from fileImporter
        let didStart = url.startAccessingSecurityScopedResource()
        defer {
            if didStart { url.stopAccessingSecurityScopedResource() }
        }

        guard let text = PDFTextExtractor.extractText(from: url) else {
            errorMessage = String(localized: "error_pdf_read")
            return
        }

        do {
            let result = try importUseCase.preview(text: text, parser: parser)
            previewTransactions = result.transactions
            duplicatesSkipped = result.duplicatesSkipped
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Save all previewed transactions.
    func saveTransactions() {
        guard hasPreview else { return }

        isLoading = true
        errorMessage = nil

        do {
            try importUseCase.save(transactions: previewTransactions)
            didSave = true
            previewTransactions = []
            duplicatesSkipped = 0
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Update category for a specific transaction in preview.
    func updateCategory(
        for transactionID: UUID,
        to newCategory: Category
    ) {
        guard let index = previewTransactions.firstIndex(
            where: { $0.id == transactionID }
        ) else { return }
        previewTransactions[index].category = newCategory
    }

    func clearPreview() {
        previewTransactions = []
        duplicatesSkipped = 0
        errorMessage = nil
    }
}
