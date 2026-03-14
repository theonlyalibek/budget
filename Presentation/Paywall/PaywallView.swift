import SwiftUI

/// Paywall sheet shown when a non-premium user taps a locked feature.
///
/// **StoreKit2 / RevenueCat plug-in point:**
/// Replace the "Оформить" button action with:
///   `Task { try await subscriptionService.purchase(productID: "...") }`
/// and the "Восстановить" button with:
///   `Task { try await subscriptionService.restorePurchases() }`
struct PaywallView: View {

    let feature: PremiumFeature

    @Environment(LocalSubscriptionService.self) private var service
    @Environment(\.dismiss) private var dismiss

    @State private var showRestoreToast = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    featureHeader
                    benefitsList
                    Divider()
                    pricingPlaceholder
                    actionButtons
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "close")) { dismiss() }
                }
            }
            .overlay {
                if showRestoreToast { restoreToast }
            }
        }
    }

    // MARK: - Header

    private var featureHeader: some View {
        VStack(spacing: 16) {
            // Gradient icon badge
            Image(systemName: feature.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Text(feature.localizedName)
                        .font(.title2.bold())
                    PremiumBadge()
                }
                Text(feature.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Benefits List

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(feature.benefits, id: \.self) { benefit in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                    Text(benefit)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Pricing

    private var pricingPlaceholder: some View {
        VStack(spacing: 6) {
            Text(String(localized: "paywall_price_placeholder"))
                .font(.title3.bold())
            Text(String(localized: "paywall_price_note"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - CTA Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary CTA — StoreKit2 hook goes here
            Button {
                // TODO: StoreKit2 purchase
                // Task { try await service.purchase(productID: "com.budget.premium.monthly") }
                showRestoreToast = true // Temporary: show "coming soon" feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showRestoreToast = false
                }
            } label: {
                Text(String(localized: "paywall_subscribe"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)

            // Restore link — StoreKit2 hook goes here
            Button {
                // TODO: StoreKit2 restore
                // Task { try await service.restorePurchases() }
                Task { try? await service.restorePurchases() }
            } label: {
                Text(String(localized: "paywall_restore"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)

            Text(String(localized: "paywall_legal"))
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Toast

    private var restoreToast: some View {
        VStack {
            Spacer()
            Text(String(localized: "paywall_coming_soon"))
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: showRestoreToast)
    }
}
