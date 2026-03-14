import SwiftUI
import Charts

struct DashboardView: View {

    @State private var viewModel: DashboardViewModel
    @State private var showInsightDetail = false
    @State private var showPaywall = false
    @Environment(LocalSubscriptionService.self) private var subscriptionService
    @EnvironmentObject private var container: DIContainer

    private let customCategoriesBinding: [CustomCategorySnapshot]

    init(viewModel: DashboardViewModel, customCategories: [CustomCategorySnapshot] = []) {
        _viewModel = State(wrappedValue: viewModel)
        self.customCategoriesBinding = customCategories
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCards
                    insightCard
                    expenseChart
                    categoryBreakdown
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "tab_dashboard"))
            .onAppear {
                viewModel.customCategories = customCategoriesBinding
                viewModel.loadStats()
            }
            .refreshable { viewModel.loadStats() }
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            .sheet(isPresented: $showInsightDetail) {
                AIInsightDetailView(stats: viewModel.stats)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(feature: .aiCoach)
            }
            .navigationDestination(for: String.self) { categoryKey in
                CategoryDetailView(
                    categoryKey: categoryKey,
                    customCategories: viewModel.customCategories,
                    repository: container.transactionRepository
                )
            }
        }
    }

    // MARK: - Balance Cards

    private var balanceCards: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "balance"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(viewModel.stats.balance))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(viewModel.stats.balance >= 0 ? .primary : .red)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            HStack(spacing: 12) {
                statMiniCard(
                    title: String(localized: "total_income"),
                    amount: viewModel.stats.totalIncome,
                    color: .green,
                    icon: "arrow.down.circle.fill"
                )
                statMiniCard(
                    title: String(localized: "total_expenses"),
                    amount: viewModel.stats.totalExpenses,
                    color: .red,
                    icon: "arrow.up.circle.fill"
                )
            }
        }
    }

    private func statMiniCard(title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
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
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - AI Insight Card

    @ViewBuilder
    private var insightCard: some View {
        if viewModel.stats.totalExpenses > 0 {
            InsightCard(
                title: String(localized: "insight_title"),
                message: String(localized: "insight_placeholder"),
                onTapDetail: {
                    if subscriptionService.isUnlocked(.aiCoach) {
                        showInsightDetail = true
                    } else {
                        showPaywall = true
                    }
                }
            )
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

                Chart(expenses, id: \.categoryItem) { item in
                    SectorMark(
                        angle: .value("amount", item.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(item.categoryItem.color)
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
                ForEach(expenses, id: \.categoryItem) { item in
                    NavigationLink(value: item.categoryItem.storageKey) {
                        dashboardCategoryRow(
                            item: item.categoryItem,
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
        } else if !viewModel.isLoading {
            EmptyStateBlock(
                systemImage: "tray",
                title: String(localized: "no_transactions"),
                description: String(localized: "no_transactions_hint")
            )
        }
    }

    private func dashboardCategoryRow(
        item: CategoryItem, amount: Double, total: Double
    ) -> some View {
        let pct = total > 0 ? amount / total : 0
        return HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.title3)
                .foregroundStyle(item.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .font(.subheadline.weight(.medium))
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(item.color.opacity(0.3))
                        .frame(width: geo.size.width)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(item.color)
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
