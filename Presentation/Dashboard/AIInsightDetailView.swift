import SwiftUI

/// AI Insight Detail screen — Flow 1: Dashboard → "Подробнее".
/// Placeholder until real AI integration in Step 4.
struct AIInsightDetailView: View {

    // Injected from Dashboard — the same stats used to generate the tip.
    let stats: DashboardStats

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header card
                    HStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "insight_title"))
                                .font(.title3.bold())
                            Text(String(localized: "insight_subtitle"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Spending summary block
                    insightSection(
                        icon: "arrow.up.circle.fill",
                        iconColor: .red,
                        title: String(localized: "total_expenses"),
                        body: CurrencyFormatter.format(stats.totalExpenses)
                    )

                    insightSection(
                        icon: "arrow.down.circle.fill",
                        iconColor: .green,
                        title: String(localized: "total_income"),
                        body: CurrencyFormatter.format(stats.totalIncome)
                    )

                    insightSection(
                        icon: "chart.pie.fill",
                        iconColor: .blue,
                        title: String(localized: "insight_top_category"),
                        body: topCategoryName
                    )

                    Divider()

                    // Static AI tip placeholder
                    VStack(alignment: .leading, spacing: 8) {
                        Label(String(localized: "insight_tip_title"), systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Text(String(localized: "insight_tip_body"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(Color.orange.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Coming soon note
                    Text(String(localized: "insight_coming_soon"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle(String(localized: "insight_detail_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "done")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Helpers

    private var topCategoryName: String {
        guard let top = stats.expensesByCategory.max(by: { $0.value < $1.value }) else {
            return String(localized: "none")
        }
        return String(localized: String.LocalizationValue(top.key.localizedKey))
    }

    @ViewBuilder
    private func insightSection(
        icon: String,
        iconColor: Color,
        title: String,
        body: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(body)
                    .font(.headline)
            }
        }
    }
}
