import SwiftUI

/// Full transaction detail screen — Figma `TransactionDetail`.
struct TransactionDetailView: View {
    let transaction: Transaction
    var customCategories: [CustomCategorySnapshot] = []
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showEdit = false

    private var categoryItem: CategoryItem {
        CategoryItem.from(storedValue: transaction.category, customCategories: customCategories)
    }

    private var subcategoryName: String {
        let key = transaction.subcategory
        guard !key.isEmpty else { return "" }
        if key.hasPrefix("custom_sub:") {
            return categoryItem.subcategoryItems
                .first { $0.storageKey == key }?
                .displayName ?? ""
        }
        return Category.localizedSubcategory(key)
    }

    var body: some View {
        List {
            // Hero amount
            Section {
                VStack(spacing: 8) {
                    Image(systemName: categoryItem.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(categoryItem.color)
                        .frame(width: 64, height: 64)
                        .background(categoryItem.color.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text(formattedAmount)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(transaction.isIncome ? .green : .primary)

                    if !transaction.note.isEmpty {
                        Text(transaction.note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }

            // Details
            Section(String(localized: "details")) {
                row(title: String(localized: "select_category"),
                    value: categoryItem.displayName,
                    icon: categoryItem.iconName,
                    iconColor: categoryItem.color)

                if !subcategoryName.isEmpty {
                    row(title: String(localized: "subcategory_label"),
                        value: subcategoryName,
                        icon: "tag.fill",
                        iconColor: categoryItem.color.opacity(0.7))
                }

                row(title: String(localized: "date"),
                    value: transaction.date.formatted(.dateTime.day().month(.wide).year()),
                    icon: "calendar",
                    iconColor: .blue)

                row(title: String(localized: "time_label"),
                    value: transaction.date.formatted(.dateTime.hour().minute()),
                    icon: "clock",
                    iconColor: .orange)

                row(title: String(localized: "transaction_type"),
                    value: transaction.isIncome
                        ? String(localized: "income_type")
                        : String(localized: "expense"),
                    icon: transaction.isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                    iconColor: transaction.isIncome ? .green : .red)
            }

            if transaction.isSubscription {
                Section {
                    Label(String(localized: "subscription_badge"), systemImage: "repeat")
                        .foregroundStyle(.indigo)
                }
            }
        }
        .navigationTitle(String(localized: "transaction_detail_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEdit = true
                    } label: {
                        Label(String(localized: "edit"), systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label(String(localized: "delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            String(localized: "delete_transaction_confirm"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "delete"), role: .destructive) {
                do {
                    try container.deleteTransactionUseCase.execute(transaction)
                    dismiss()
                } catch {
                    // Deletion failed silently — user stays on detail
                }
            }
            Button(String(localized: "cancel"), role: .cancel) { }
        }
        .navigationDestination(isPresented: $showEdit) {
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

    // MARK: - Helpers

    private var formattedAmount: String {
        let prefix = transaction.isIncome ? "+ " : "- "
        return prefix + CurrencyFormatter.format(transaction.amount)
    }

    private func row(title: String, value: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}
