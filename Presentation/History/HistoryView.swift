import SwiftUI

struct HistoryView: View {

    @State private var viewModel: HistoryViewModel
    @State private var showFilters = false

    init(viewModel: HistoryViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segment picker
                Picker("", selection: $viewModel.selectedSegment) {
                    ForEach(HistorySegment.allCases) { seg in
                        Text(String(localized: String.LocalizationValue(seg.localizedKey)))
                            .tag(seg)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Content
                Group {
                    if viewModel.sections.isEmpty && !viewModel.isLoading {
                        EmptyStateBlock(
                            systemImage: "tray",
                            title: String(localized: "no_transactions"),
                            description: String(localized: "no_transactions_hint")
                        )
                    } else {
                        transactionList
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "tab_history"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: viewModel.hasActiveFilters
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear { viewModel.loadTransactions() }
            .onChange(of: viewModel.selectedSegment) { _, _ in
                viewModel.loadTransactions()
            }
            .refreshable { viewModel.loadTransactions() }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .sheet(isPresented: $showFilters) {
                HistoryFiltersSheet(
                    selectedCategories: $viewModel.filterCategories,
                    startDate: $viewModel.filterStartDate,
                    endDate: $viewModel.filterEndDate,
                    onApply: { viewModel.loadTransactions() },
                    onReset: { viewModel.resetFilters() }
                )
                .presentationDetents([.medium, .large])
            }
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(transaction: transaction)
            }
        }
    }

    // MARK: - List

    private var transactionList: some View {
        List {
            ForEach(viewModel.sections) { section in
                Section {
                    ForEach(section.transactions, id: \.id) { transaction in
                        NavigationLink(value: transaction) {
                            historyTransactionRow(transaction)
                        }
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

    // MARK: - Row

    private func historyTransactionRow(_ transaction: Transaction) -> some View {
        let category = Category(rawValue: transaction.category) ?? .other
        return HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(category.color)
                .frame(width: 36, height: 36)
                .background(category.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

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

            Text(formattedAmount(transaction))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(transaction.isIncome ? .green : .primary)
        }
        .padding(.vertical, 2)
    }

    private func formattedAmount(_ t: Transaction) -> String {
        let prefix = t.isIncome ? "+ " : "- "
        return prefix + CurrencyFormatter.format(t.amount)
    }
}
