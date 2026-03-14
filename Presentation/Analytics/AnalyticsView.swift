import SwiftUI
import Charts

/// Analytics tab (Аналитика) — Figma Tab 4.
/// Period-switchable expense breakdown with pie chart and category rows.
struct AnalyticsView: View {

    @State private var viewModel: AnalyticsViewModel
    @EnvironmentObject private var container: DIContainer

    init(viewModel: AnalyticsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    periodPicker
                    summaryCards
                    expenseChart
                    categoryBreakdown
                }
                .padding()
            }
            .navigationTitle(String(localized: "tab_analytics"))
            .onAppear { viewModel.loadStats() }
            .onChange(of: viewModel.selectedPeriod) { _, _ in
                viewModel.loadStats()
            }
            .refreshable { viewModel.loadStats() }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .navigationDestination(for: Category.self) { category in
                CategoryDetailView(
                    category: category,
                    repository: container.transactionRepository
                )
            }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        Picker(String(localized: "period"), selection: $viewModel.selectedPeriod) {
            ForEach(AnalyticsPeriod.allCases) { period in
                Text(String(localized: String.LocalizationValue(period.localizedKey)))
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Summary

    private var summaryCards: some View {
        HStack(spacing: 12) {
            miniCard(
                title: String(localized: "total_income"),
                amount: viewModel.stats.totalIncome,
                color: .green,
                icon: "arrow.down.circle.fill"
            )
            miniCard(
                title: String(localized: "total_expenses"),
                amount: viewModel.stats.totalExpenses,
                color: .red,
                icon: "arrow.up.circle.fill"
            )
        }
    }

    private func miniCard(title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(CurrencyFormatter.format(amount))
                .font(.title3.bold())
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Pie Chart

    @ViewBuilder
    private var expenseChart: some View {
        let expenses = viewModel.sortedExpenses
        if expenses.isEmpty && !viewModel.isLoading {
            EmptyStateBlock(
                systemImage: "chart.pie",
                title: String(localized: "no_transactions"),
                description: String(localized: "no_transactions_hint")
            )
            .frame(height: 200)
        } else if !expenses.isEmpty {
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
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Category Breakdown

    @ViewBuilder
    private var categoryBreakdown: some View {
        let expenses = viewModel.sortedExpenses
        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "expenses_by_category"))
                    .font(.headline)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)

                ForEach(expenses, id: \.category) { item in
                    NavigationLink(value: item.category) {
                        analyticsCategoryRow(
                            category: item.category,
                            amount: item.amount,
                            total: viewModel.stats.totalExpenses
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func analyticsCategoryRow(
        category: Category, amount: Double, total: Double
    ) -> some View {
        let pct = total > 0 ? amount / total : 0
        return HStack(spacing: 12) {
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
                                .frame(width: geo.size.width * pct)
                        }
                }
                .frame(height: 4)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(CurrencyFormatter.format(amount))
                    .font(.subheadline.weight(.semibold))
                Text("\(Int(pct * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
