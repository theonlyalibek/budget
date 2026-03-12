import SwiftUI
import Charts

struct DashboardView: View {

    @State private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCards
                    expenseChart
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle(String(localized: "tab_dashboard"))
            .onAppear { viewModel.loadStats() }
            .refreshable { viewModel.loadStats() }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }

    // MARK: - Balance Cards

    private var balanceCards: some View {
        VStack(spacing: 12) {
            // Balance
            StatCard(
                title: String(localized: "balance"),
                amount: viewModel.stats.balance,
                color: viewModel.stats.balance >= 0 ? .primary : .red,
                isLarge: true
            )

            HStack(spacing: 12) {
                // Income
                StatCard(
                    title: String(localized: "total_income"),
                    amount: viewModel.stats.totalIncome,
                    color: .green,
                    systemImage: "arrow.down.circle.fill"
                )

                // Expenses
                StatCard(
                    title: String(localized: "total_expenses"),
                    amount: viewModel.stats.totalExpenses,
                    color: .red,
                    systemImage: "arrow.up.circle.fill"
                )
            }
        }
    }

    // MARK: - Pie Chart

    @ViewBuilder
    private var expenseChart: some View {
        let expenses = viewModel.sortedExpenses
        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "expenses_by_category"))
                    .font(.headline)

                Chart(expenses, id: \.category) { item in
                    SectorMark(
                        angle: .value("amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(4)
                }
                .frame(height: 220)
                .chartBackground { _ in
                    VStack {
                        Text(String(localized: "total"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(viewModel.stats.totalExpenses))
                            .font(.title3.bold())
                    }
                }
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Category Breakdown List

    @ViewBuilder
    private var categoryBreakdown: some View {
        let expenses = viewModel.sortedExpenses
        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(expenses, id: \.category) { item in
                    CategoryRow(
                        category: item.category,
                        amount: item.amount,
                        total: viewModel.stats.totalExpenses
                    )
                }
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        } else if !viewModel.isLoading {
            ContentUnavailableView(
                String(localized: "no_transactions"),
                systemImage: "tray",
                description: Text(String(localized: "no_transactions_hint"))
            )
        }
    }
}

// MARK: - StatCard

private struct StatCard: View {
    let title: String
    let amount: Double
    let color: Color
    var isLarge: Bool = false
    var systemImage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(color)
                        .font(.subheadline)
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(CurrencyFormatter.format(amount))
                .font(isLarge ? .largeTitle.bold() : .title2.bold())
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - CategoryRow

private struct CategoryRow: View {
    let category: Category
    let amount: Double
    let total: Double

    private var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconName)
                .font(.title3)
                .foregroundStyle(category.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: String.LocalizationValue(category.localizedKey)))
                    .font(.subheadline.weight(.medium))

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(category.color.opacity(0.3))
                        .frame(width: geo.size.width)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(category.color)
                                .frame(width: geo.size.width * percentage)
                        }
                }
                .frame(height: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(amount))
                    .font(.subheadline.weight(.semibold))
                Text("\(Int(percentage * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
