import SwiftUI

struct SubscriptionsView: View {

    @State private var viewModel: SubscriptionsViewModel

    init(viewModel: SubscriptionsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    String(localized: "no_subscriptions"),
                    systemImage: "repeat.circle",
                    description: Text(String(localized: "no_subscriptions_hint"))
                )
            } else {
                subscriptionList
            }
        }
        .navigationTitle(String(localized: "subscriptions_title"))
        .onAppear { viewModel.load() }
    }

    // MARK: - List

    private var subscriptionList: some View {
        List {
            // Total header
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "monthly_total"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(viewModel.totalMonthly))
                        .font(.largeTitle.bold())
                        .foregroundStyle(.red)
                        .contentTransition(.numericText())
                }
                .padding(.vertical, 8)
            }

            // Subscription rows
            Section(String(localized: "active_subscriptions")) {
                ForEach(viewModel.subscriptions) { item in
                    SubscriptionRow(item: item)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Subscription Row

private struct SubscriptionRow: View {
    let item: SubscriptionItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.category.iconName)
                .font(.title3)
                .foregroundStyle(item.category.color)
                .frame(width: 36, height: 36)
                .background(item.category.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.merchant)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(String(localized: String.LocalizationValue(item.category.localizedKey)))
                    if item.occurrences > 1 {
                        Text("·")
                        Text(String(localized: "times \(item.occurrences)"))
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(item.lastAmount))
                    .font(.subheadline.weight(.semibold))
                Text(item.lastDate, format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
