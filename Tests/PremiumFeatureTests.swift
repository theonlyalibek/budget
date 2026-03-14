import XCTest
@testable import budget

/// Verifies PremiumFeature enum completeness, identifiable uniqueness,
/// and that gating logic in LocalSubscriptionService is consistent.
@MainActor
final class PremiumFeatureTests: XCTestCase {

    // MARK: - Identifiable

    func test_allCases_haveUniqueIDs() {
        let ids = PremiumFeature.allCases.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count,
            "All PremiumFeature cases must have unique IDs (rawValues)")
    }

    func test_allCases_idEqualsRawValue() {
        for feature in PremiumFeature.allCases {
            XCTAssertEqual(feature.id, feature.rawValue)
        }
    }

    // MARK: - Metadata completeness

    func test_allCases_haveNonEmptyIconName() {
        for feature in PremiumFeature.allCases {
            XCTAssertFalse(feature.iconName.isEmpty,
                "\(feature.rawValue) must have a non-empty SF Symbol name")
        }
    }

    func test_allCases_haveAtLeastOneBenefit() {
        for feature in PremiumFeature.allCases {
            XCTAssertFalse(feature.benefits.isEmpty,
                "\(feature.rawValue) must list at least one benefit string")
        }
    }

    func test_allCases_benefitsAreNonEmpty() {
        for feature in PremiumFeature.allCases {
            for (i, benefit) in feature.benefits.enumerated() {
                XCTAssertFalse(benefit.isEmpty,
                    "\(feature.rawValue) benefit[\(i)] must not be an empty string")
            }
        }
    }

    // MARK: - Gating consistency with LocalSubscriptionService

    func test_freeUser_noFeaturesUnlocked() {
        let defaults = UserDefaults(suiteName: "com.budget.tests.premiumfeature")!
        defaults.removePersistentDomain(forName: "com.budget.tests.premiumfeature")
        let service = LocalSubscriptionService(defaults: defaults)

        for feature in PremiumFeature.allCases {
            XCTAssertFalse(service.isUnlocked(feature),
                "\(feature.rawValue) must be locked for a free user")
        }
        defaults.removePersistentDomain(forName: "com.budget.tests.premiumfeature")
    }

    #if DEBUG
    func test_premiumUser_allFeaturesUnlocked() {
        let defaults = UserDefaults(suiteName: "com.budget.tests.premiumfeature2")!
        defaults.removePersistentDomain(forName: "com.budget.tests.premiumfeature2")
        let service = LocalSubscriptionService(defaults: defaults)
        service.toggleDebugSubscription()

        for feature in PremiumFeature.allCases {
            XCTAssertTrue(service.isUnlocked(feature),
                "\(feature.rawValue) must be unlocked for a premium user")
        }
        defaults.removePersistentDomain(forName: "com.budget.tests.premiumfeature2")
    }
    #endif

    // MARK: - Count guard
    // Fails if a new case is added without updating tests — acts as a reminder.
    func test_exactlyThreeCases() {
        XCTAssertEqual(PremiumFeature.allCases.count, 3,
            "Expected 3 PremiumFeature cases. If you added a new one, update this test and add coverage.")
    }
}
