import Foundation
import Observation

/// Local (offline) stub implementation of `SubscriptionServiceProtocol`.
///
/// Persists entitlement in `UserDefaults` so the state survives app restarts
/// during QA / TestFlight without requiring real IAP. In production, swap this
/// for a `StoreKitSubscriptionService` in `DIContainer` — no view code changes.
///
/// **StoreKit2 / RevenueCat wiring (Step 5+):**
/// 1. Create `StoreKitSubscriptionService: SubscriptionServiceProtocol`.
/// 2. Call `Transaction.currentEntitlements` in `restorePurchases()`.
/// 3. In `DIContainer`, replace `LocalSubscriptionService()` with the new type.
/// 4. Remove the `#if DEBUG` toggle from `SettingsView`.
@MainActor
@Observable
final class LocalSubscriptionService: SubscriptionServiceProtocol {

    // MARK: - State

    private(set) var isSubscribed: Bool

    // MARK: - Storage

    private static let defaultsKey = "budget_premium_unlocked"

    // MARK: - Init

    init() {
        // Free tier by default in production; read persisted flag for QA use.
        isSubscribed = UserDefaults.standard.bool(forKey: Self.defaultsKey)
    }

    // MARK: - SubscriptionServiceProtocol

    func isUnlocked(_ feature: PremiumFeature) -> Bool {
        // MVP: single "premium" tier unlocks all features.
        // Future: per-feature entitlement checks via StoreKit2 product IDs.
        isSubscribed
    }

    func restorePurchases() async throws {
        // StoreKit2 plug-in point — no-op for local stub.
        // Replace with:
        //   for await result in Transaction.currentEntitlements { ... }
    }

    // MARK: - DEBUG

    #if DEBUG
    /// Toggles subscription state for QA / Simulator testing.
    /// Exposed via Settings → Debug in non-release builds only.
    func toggleDebugSubscription() {
        isSubscribed.toggle()
        UserDefaults.standard.set(isSubscribed, forKey: Self.defaultsKey)
    }
    #endif
}
