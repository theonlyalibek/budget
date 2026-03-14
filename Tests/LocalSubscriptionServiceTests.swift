import XCTest
@testable import budget

/// Unit tests for LocalSubscriptionService.
///
/// Uses an isolated UserDefaults suite so tests never pollute the real user's
/// defaults and can run independently in any order.
@MainActor
final class LocalSubscriptionServiceTests: XCTestCase {

    // MARK: - Setup

    private static let testSuite = "com.budget.tests.subscriptions"
    private var testDefaults: UserDefaults!
    private var service: LocalSubscriptionService!

    override func setUp() {
        super.setUp()
        // Isolated suite — wipe before each test for determinism.
        testDefaults = UserDefaults(suiteName: Self.testSuite)!
        testDefaults.removePersistentDomain(forName: Self.testSuite)
        service = LocalSubscriptionService(defaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: Self.testSuite)
        testDefaults = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Tests

    /// New service must default to free tier — no purchases persisted.
    func test_defaultIsSubscribed_isFalse() {
        XCTAssertFalse(service.isSubscribed,
            "A fresh LocalSubscriptionService must be unsubscribed by default.")
    }

    /// isUnlocked must mirror isSubscribed for every PremiumFeature.
    func test_isUnlocked_followsIsSubscribed_whenFree() {
        XCTAssertFalse(service.isSubscribed)
        for feature in PremiumFeature.allCases {
            XCTAssertFalse(
                service.isUnlocked(feature),
                "\(feature.rawValue) should be locked when isSubscribed == false"
            )
        }
    }

    /// isUnlocked must return true for all features after subscribing.
    func test_isUnlocked_followsIsSubscribed_whenPremium() {
        // Simulate premium by toggling in DEBUG.
        #if DEBUG
        service.toggleDebugSubscription()
        XCTAssertTrue(service.isSubscribed)
        for feature in PremiumFeature.allCases {
            XCTAssertTrue(
                service.isUnlocked(feature),
                "\(feature.rawValue) should be unlocked when isSubscribed == true"
            )
        }
        #else
        // In release builds the toggle is unavailable; just assert the free state.
        XCTAssertFalse(service.isSubscribed)
        #endif
    }

    #if DEBUG
    /// Toggle must flip isSubscribed and persist the new value to UserDefaults.
    func test_debugToggle_flipsStateAndPersists() {
        XCTAssertFalse(service.isSubscribed)

        // First toggle: false → true
        service.toggleDebugSubscription()
        XCTAssertTrue(service.isSubscribed, "After first toggle isSubscribed should be true.")

        // Persisted value must match in-memory state.
        let persisted = testDefaults.bool(forKey: "budget_premium_unlocked")
        XCTAssertTrue(persisted, "UserDefaults must reflect the toggled value.")

        // Second toggle: true → false
        service.toggleDebugSubscription()
        XCTAssertFalse(service.isSubscribed, "After second toggle isSubscribed should be false.")
        XCTAssertFalse(
            testDefaults.bool(forKey: "budget_premium_unlocked"),
            "UserDefaults must reflect the re-toggled value."
        )
    }

    /// A new instance created after a toggle must read the persisted state correctly.
    func test_debugToggle_persistsAcrossInstances() {
        service.toggleDebugSubscription()                       // set to true
        let newService = LocalSubscriptionService(defaults: testDefaults)
        XCTAssertTrue(newService.isSubscribed,
            "A new instance reading the same defaults must see the persisted subscribed state.")
    }
    #endif

    /// restorePurchases() must not throw for the local stub (no-op contract).
    func test_restorePurchases_doesNotThrow() async {
        await XCTAssertNoThrowAsync {
            try await self.service.restorePurchases()
        }
    }
}

// MARK: - XCTest async helper

/// Asserts that an async throwing expression does not throw.
func XCTAssertNoThrowAsync(
    _ expression: @escaping () async throws -> Void,
    file: StaticString = #file,
    line: UInt = #line
) async {
    do {
        try await expression()
    } catch {
        XCTFail("Unexpected throw: \(error)", file: file, line: line)
    }
}
