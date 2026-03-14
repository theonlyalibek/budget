import XCTest
@testable import budget

final class CategorizationEngineTests: XCTestCase {

    private var engine: CategorizationEngine!

    override func setUp() {
        super.setUp()
        engine = CategorizationEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Transport

    func testYandexGoCategorizesAsTransport() {
        let result = engine.categorize("Yandex Go поездка")
        XCTAssertEqual(result.category, .transport)
        XCTAssertEqual(result.subcategory, "Такси")
    }

    func testUberCategorizesAsTransport() {
        let result = engine.categorize("Uber BV trip")
        XCTAssertEqual(result.category, .transport)
    }

    func testInDriverCategorizesAsTransport() {
        let result = engine.categorize("INDRIVE payment")
        XCTAssertEqual(result.category, .transport)
    }

    // MARK: - Food

    func testStarbucksCategorizesAsFood() {
        let result = engine.categorize("STARBUCKS ALMATY")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Кафе")
    }

    func testMagnumCategorizesAsFood() {
        let result = engine.categorize("Magnum Cash&Carry")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Продукты")
    }

    func testGlovoCategorizesAsFood() {
        let result = engine.categorize("Glovo delivery order")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Доставка еды")
    }

    func testMcDonaldsCategorizesAsFood() {
        let result = engine.categorize("McDonalds Almaty Mega")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Фастфуд")
    }

    // MARK: - Entertainment & Subscriptions

    func testSpotifyCategorizesAsEntertainmentSubscription() {
        let result = engine.categorize("Spotify Premium monthly")
        XCTAssertEqual(result.category, .entertainment)
        XCTAssertTrue(result.isSubscription)
    }

    func testNetflixCategorizesAsSubscription() {
        let result = engine.categorize("NETFLIX.COM payment")
        XCTAssertEqual(result.category, .entertainment)
        XCTAssertTrue(result.isSubscription)
    }

    // MARK: - Subscriptions (standalone)

    func testICloudCategorizesAsSubscription() {
        let result = engine.categorize("APPLE.COM/BILL iCloud+ 50GB")
        XCTAssertEqual(result.category, .subscriptions)
        XCTAssertTrue(result.isSubscription)
    }

    // MARK: - Clothing

    func testZaraCategorizesAsClothing() {
        let result = engine.categorize("ZARA Dostyk Plaza")
        XCTAssertEqual(result.category, .clothing)
    }

    // MARK: - Health

    func testPharmacyCategorizesAsHealth() {
        let result = engine.categorize("Аптека Europharma")
        XCTAssertEqual(result.category, .health)
    }

    // MARK: - Transfers

    func testP2PCategorizesAsTransfer() {
        let result = engine.categorize("P2P перевод Иванову")
        XCTAssertEqual(result.category, .transfers)
    }

    // MARK: - Utilities

    func testBeelineCategorizesAsUtilities() {
        let result = engine.categorize("Beeline пополнение")
        XCTAssertEqual(result.category, .utilities)
    }

    // MARK: - Unknown / Other

    func testUnknownMerchantReturnsOther() {
        let result = engine.categorize("RANDOM MERCHANT XYZ-123")
        XCTAssertEqual(result.category, .other)
        XCTAssertFalse(result.isSubscription)
    }

    func testEmptyStringReturnsOther() {
        let result = engine.categorize("")
        XCTAssertEqual(result.category, .other)
    }

    // MARK: - Case Insensitivity

    func testCaseInsensitiveMatching() {
        let lower = engine.categorize("magnum")
        let upper = engine.categorize("MAGNUM")
        let mixed = engine.categorize("MaGnUm CaSh&CaRrY")
        XCTAssertEqual(lower.category, .food)
        XCTAssertEqual(upper.category, .food)
        XCTAssertEqual(mixed.category, .food)
    }

    // MARK: - User Rules Override

    func testUserRuleTakesPriorityOverBuiltIn() {
        let userRules = [
            CategoryRule(keyword: "magnum", categoryName: "entertainment")
        ]
        let result = engine.categorize("Magnum Cash&Carry", userRules: userRules)
        XCTAssertEqual(result.category, .entertainment, "User rules should override built-in rules")
    }

    // MARK: - Real Kaspi statement merchants

    func testWoltCategorizesAsDelivery() {
        let result = engine.categorize("WOLT.COM")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Доставка еды")
    }

    func testFreshMarketCategorizesAsGroceries() {
        let result = engine.categorize("fresh market")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Продукты")
    }

    func testParkingCategorizesAsTransport() {
        let result = engine.categorize("Алматы Паркинг. Оплата парковок Алматы")
        XCTAssertEqual(result.category, .transport)
        XCTAssertEqual(result.subcategory, "Парковка")
    }

    func testDodoPayCategorizesAsFastFood() {
        let result = engine.categorize("DP* DODOPAY SRIKANTH")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Фастфуд")
    }

    func testFacebookCategorizesAsSubscription() {
        let result = engine.categorize("FACEBK *U9G23FDR62")
        XCTAssertEqual(result.category, .subscriptions)
        XCTAssertTrue(result.isSubscription)
    }

    func testZypZypCategorizesAsCafe() {
        let result = engine.categorize("ZYP ZYP")
        XCTAssertEqual(result.category, .food)
        XCTAssertEqual(result.subcategory, "Кафе")
    }

    func testUserRuleWithUnknownCategoryFallsToOther() {
        let userRules = [
            CategoryRule(keyword: "testshop", categoryName: "nonexistent_category")
        ]
        let result = engine.categorize("TestShop purchase", userRules: userRules)
        XCTAssertEqual(result.category, .other)
    }
}
