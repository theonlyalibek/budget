import Foundation
import Observation

/// Segment for History tab — Figma shows Все / Расходы / Доходы.
enum HistorySegment: String, CaseIterable, Identifiable {
    case all
    case expenses
    case income

    var id: String { rawValue }

    var localizedKey: String {
        switch self {
        case .all:      "segment_all"
        case .expenses: "segment_expenses"
        case .income:   "segment_income"
        }
    }
}

/// A group of transactions sharing the same calendar day.
struct TransactionSection: Identifiable {
    let id: String
    let title: String
    let transactions: [Transaction]
}

@MainActor
@Observable
final class HistoryViewModel {

    // MARK: - State

    private(set) var sections: [TransactionSection] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var selectedSegment: HistorySegment = .all
    var filterCategories: Set<Category> = []
    var filterStartDate: Date?
    var filterEndDate: Date?

    // MARK: - Dependencies

    private let repository: TransactionRepositoryProtocol

    // MARK: - Init

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    func loadTransactions() {
        isLoading = true
        errorMessage = nil

        do {
            var filter = TransactionFilter.all

            // Segment
            switch selectedSegment {
            case .all:      break
            case .expenses: filter = TransactionFilter(isIncome: false)
            case .income:   filter = TransactionFilter(isIncome: true)
            }

            // Date range
            if let start = filterStartDate {
                filter = TransactionFilter(
                    startDate: start,
                    endDate: filterEndDate,
                    category: filter.category,
                    isIncome: filter.isIncome
                )
            }

            let all = try repository.fetch(filter: filter)

            // Category filter (client-side for simplicity)
            let filtered: [Transaction]
            if filterCategories.isEmpty {
                filtered = all
            } else {
                let categoryNames = filterCategories.map(\.rawValue)
                filtered = all.filter { categoryNames.contains($0.category) }
            }

            sections = groupByDate(filtered)
        } catch {
            errorMessage = error.localizedDescription
            sections = []
        }

        isLoading = false
    }

    func deleteTransaction(_ transaction: Transaction) {
        do {
            try repository.delete(transaction)
            loadTransactions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetFilters() {
        filterCategories = []
        filterStartDate = nil
        filterEndDate = nil
        loadTransactions()
    }

    var hasActiveFilters: Bool {
        !filterCategories.isEmpty || filterStartDate != nil
    }

    // MARK: - Grouping

    private func groupByDate(_ transactions: [Transaction]) -> [TransactionSection] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date)
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { (day, items) in
                TransactionSection(
                    id: DateFormatters.dayMonthYear.string(from: day),
                    title: relativeTitle(for: day, calendar: calendar),
                    transactions: items.sorted { $0.date > $1.date }
                )
            }
    }

    private func relativeTitle(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) {
            return String(localized: "today")
        } else if calendar.isDateInYesterday(date) {
            return String(localized: "yesterday")
        } else {
            return date.formatted(.dateTime.day().month(.wide).year())
        }
    }
}
