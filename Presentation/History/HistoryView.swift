import SwiftUI

struct HistoryView: View {

    @State private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sections.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        String(localized: "no_transactions"),
                        systemImage: "tray",
                        description: Text(String(localized: "no_transactions_hint"))
                    )
                } else {
                    transactionList
                }
            }
            .navigationTitle(String(localized: "tab_history"))
            .onAppear { viewModel.loadTransactions() }
            .refreshable { viewModel.loadTransactions() }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - List

    private var transactionList: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section {
                    ForEach(section.transactions, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction)
                                } label: {
                                    Label(String(localized: "delete"), systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text(section.title)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Transaction Row

private struct TransactionRow: View {
    let transaction: Transaction

    private var category: Category {
        Category(rawValue: transaction.category) ?? .other
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(category.color)
                .frame(width: 36, height: 36)
                .background(category.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Merchant + category
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.note.isEmpty
                     ? String(localized: String.LocalizationValue(category.localizedKey))
                     : transaction.note)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(String(localized: String.LocalizationValue(category.localizedKey)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text(formattedAmount)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(transaction.isIncome ? .green : .primary)
        }
        .padding(.vertical, 2)
    }

    private var formattedAmount: String {
        let prefix = transaction.isIncome ? "+ " : "- "
        return prefix + CurrencyFormatter.format(transaction.amount)
    }
}
