import Foundation

/// Contract for subscription entitlement checks.
///
/// **StoreKit2 / RevenueCat plug-in point:**
/// Implement a new concrete type (e.g. `StoreKitSubscriptionService`) conforming
/// to this protocol. Swap the concrete type in `DIContainer` and `BudgetApp`;
/// no view code changes needed.
///
/// ```swift
/// // Future: StoreKitSubscriptionService
/// func restorePurchases() async throws {
///     for await result in Transaction.currentEntitlements {
///         if case .verified(let tx) = result {
///             isSubscribed = tx.productID == "com.budget.premium.monthly"
///         }
///     }
/// }
/// ```
@MainActor
protocol SubscriptionServiceProtocol: AnyObject {
    /// True when user holds a valid premium entitlement.
    var isSubscribed: Bool { get }

    /// Returns true if the given feature is accessible under the current plan.
    /// All features map to `isSubscribed` for MVP; can be per-feature later.
    func isUnlocked(_ feature: PremiumFeature) -> Bool

    /// Async hook for StoreKit2 / RevenueCat restore flow.
    /// No-op in `LocalSubscriptionService`.
    func restorePurchases() async throws
}
