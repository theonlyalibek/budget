import Foundation
import Observation

/// A group of transactions sharing the same calendar day.
struct TransactionSection: Identifiable {
    let id: String          // formatted date string as stable ID
    let title: String       // display title ("Сегодня", "Вчера", or "12 марта 2026")
    let transactions: [Transaction]
}

@MainActor
@Observable
final class HistoryViewModel {

    // MARK: - State

    private(set) var sections: [TransactionSection] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

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
            let all = try repository.fetch(filter: .all)
            sections = groupByDate(all)
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
