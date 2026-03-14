import SwiftUI

/// Generic view that renders `content` when the feature is unlocked,
/// or a locked row (with PRO badge) that opens `PaywallView` when tapped.
///
/// Usage in a List / Form:
/// ```swift
/// FeatureGate(feature: .financialLessons) {
///     NavigationLink("Финансовая грамотность") { LessonsView() }
/// }
/// ```
/// Usage for any arbitrary view:
/// ```swift
/// FeatureGate(feature: .aiCoach) {
///     AICoachView()
/// }
/// ```
struct FeatureGate<Content: View>: View {

    let feature: PremiumFeature

    @Environment(LocalSubscriptionService.self) private var service
    @State private var showPaywall = false

    @ViewBuilder var content: () -> Content

    var body: some View {
        Group {
            if service.isUnlocked(feature) {
                content()
            } else {
                lockedRow
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: feature)
        }
    }

    // MARK: - Locked Row

    private var lockedRow: some View {
        HStack(spacing: 12) {
            Image(systemName: feature.iconName)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            Text(feature.localizedName)
                .foregroundStyle(.primary)

            Spacer()

            PremiumBadge()
        }
        .contentShape(Rectangle())
        .onTapGesture { showPaywall = true }
    }
}
