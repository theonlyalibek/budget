import SwiftUI

struct HistoryView: View {

    @EnvironmentObject private var container: DIContainer
    @State private var viewModel: HistoryViewModel
    @State private var showFilters = false
    @State private var transactionToEdit: Transaction?
    let customCategories: [CustomCategorySnapshot]

    init(viewModel: HistoryViewModel, customCategories: [CustomCategorySnapshot] = []) {
        _viewModel = State(wrappedValue: viewModel)
        self.customCategories = customCategories
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
                    customCategories: customCategories,
                    onApply: { viewModel.loadTransactions() },
                    onReset: { viewModel.resetFilters() }
                )
                .presentationDetents([.medium, .large])
            }
            .navigationDestination(for: Transaction.self) { transaction in
                TransactionDetailView(
                    transaction: transaction,
                    customCategories: customCategories
                )
            }
            .sheet(item: $transactionToEdit) { transaction in
                NavigationStack {
                    EditTransactionView(
                        viewModel: EditTransactionViewModel(
                            transaction: transaction,
                            updateUseCase: container.updateTransactionUseCase,
                            deleteUseCase: container.deleteTransactionUseCase,
                            customCategories: customCategories
                        )
                    )
                }
            }
            .onChange(of: transactionToEdit) { _, newValue in
                // Reload after returning from edit (newValue becomes nil on dismiss)
                if newValue == nil {
                    viewModel.loadTransactions()
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
                        .swipeActions(edge: .trailing) {
                            Button {
                                transactionToEdit = transaction
                            } label: {
                                Label(String(localized: "edit"), systemImage: "pencil")
                            }
                            .tint(.blue)
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
        let catItem = CategoryItem.from(
            storedValue: transaction.category,
            customCategories: customCategories
        )
        let subcategoryName: String = {
            if transaction.subcategory.isEmpty { return "" }
            if transaction.subcategory.hasPrefix("custom_sub:") {
                // Resolve from custom category's subcategory snapshots
                return catItem.subcategoryItems
                    .first { $0.storageKey == transaction.subcategory }?
                    .displayName ?? ""
            }
            return Category.localizedSubcategory(transaction.subcategory)
        }()

        return HStack(spacing: 12) {
            Image(systemName: catItem.iconName)
                .font(.title3)
                .foregroundStyle(catItem.color)
                .frame(width: 36, height: 36)
                .background(catItem.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.note.isEmpty
                     ? catItem.displayName
                     : transaction.note)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(catItem.displayName)
                    if !subcategoryName.isEmpty {
                        Text("·")
                        Text(subcategoryName)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
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
