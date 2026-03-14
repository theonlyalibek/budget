import SwiftUI

/// Full transaction detail screen — Figma `TransactionDetail`.
struct TransactionDetailView: View {
    let transaction: Transaction

    private var category: Category {
        Category(rawValue: transaction.category) ?? .other
    }

    var body: some View {
        List {
            // Hero amount
            Section {
                VStack(spacing: 8) {
                    Image(systemName: category.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(category.color)
                        .frame(width: 64, height: 64)
                        .background(category.color.opacity(0.12))
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
                    value: String(localized: String.LocalizationValue(category.localizedKey)),
                    icon: category.iconName,
                    iconColor: category.color)

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
