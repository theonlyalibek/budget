import SwiftUI

/// Drilldown screen for a single expense category — Figma `CategoryDetail`.
struct CategoryDetailView: View {
    @State private var viewModel: CategoryDetailViewModel

    init(category: Category, repository: TransactionRepositoryProtocol) {
        _viewModel = State(wrappedValue: CategoryDetailViewModel(
            category: category,
            repository: repository
        ))
    }

    var body: some View {
        Group {
            if viewModel.transactions.isEmpty && !viewModel.isLoading {
                EmptyStateBlock(
                    systemImage: "tray",
                    title: String(localized: "no_transactions")
                )
            } else {
                List {
                    // Total header
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "total"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(CurrencyFormatter.format(viewModel.totalAmount))
                                .font(.system(size: 34, weight: .bold))
                            Text(String(localized: "transactions_count \(viewModel.transactions.count)"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    // Transaction list
                    Section {
                        ForEach(viewModel.transactions, id: \.id) { transaction in
                            NavigationLink(value: transaction) {
                                categoryTransactionRow(transaction)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(
            String(localized: String.LocalizationValue(viewModel.category.localizedKey))
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .navigationDestination(for: Transaction.self) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }

    private func categoryTransactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.note.isEmpty
                     ? String(localized: String.LocalizationValue(viewModel.category.localizedKey))
                     : transaction.note)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(transaction.date.formatted(.dateTime.day().month(.abbreviated)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("- " + CurrencyFormatter.format(transaction.amount))
                .font(.subheadline.weight(.semibold))
        }
    }
}
