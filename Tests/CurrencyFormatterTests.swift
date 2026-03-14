import XCTest
@testable import budget

final class CurrencyFormatterTests: XCTestCase {

    // MARK: - Symbol

    func test_format_alwaysContainsTengeSymbol() {
        let result = CurrencyFormatter.format(1000)
        XCTAssertTrue(result.contains("₸"),
            "Formatted amount must contain ₸ symbol, got: \(result)")
    }

    func test_format_zero_containsTengeSymbol() {
        let result = CurrencyFormatter.format(0)
        XCTAssertTrue(result.contains("₸"),
            "Zero amount must still contain ₸ symbol, got: \(result)")
    }

    // MARK: - No decimal places

    func test_format_wholeAmount_hasNoDecimalSeparator() {
        let result = CurrencyFormatter.format(5000)
        // KZT amounts have maximumFractionDigits = 0, so no "." or ","
        XCTAssertFalse(result.contains("."),
            "KZT format must not show decimal point, got: \(result)")
    }

    func test_format_fractionalAmount_isRounded() {
        let result = CurrencyFormatter.format(1234.56)
        // Should not show cents — maximumFractionDigits = 0
        XCTAssertFalse(result.contains("."),
            "Fractional tenge must be rounded, not shown with decimal, got: \(result)")
    }

    // MARK: - Numeric content

    func test_format_1000_containsDigits() {
        let result = CurrencyFormatter.format(1000)
        XCTAssertTrue(result.contains("1") && result.contains("0"),
            "Formatted 1000 must contain its digits, got: \(result)")
    }

    func test_format_largeAmount_doesNotCrash() {
        // Regression: ensure formatter handles values up to typical KZT salaries
        let result = CurrencyFormatter.format(1_500_000)
        XCTAssertFalse(result.isEmpty,
            "Formatting a large amount must not return empty string")
        XCTAssertTrue(result.contains("₸"))
    }

    // MARK: - Fallback path

    func test_format_negativeAmount_containsTengeSymbol() {
        // Negative balances (e.g. Dashboard balance when expenses > income)
        let result = CurrencyFormatter.format(-500)
        XCTAssertTrue(result.contains("₸"),
            "Negative amount must still carry ₸ symbol, got: \(result)")
    }

    // MARK: - KZT code

    func test_formatter_currencyCode_isKZT() {
        XCTAssertEqual(CurrencyFormatter.tenge.currencyCode, "KZT")
    }

    func test_formatter_currencySymbol_isTenge() {
        XCTAssertEqual(CurrencyFormatter.tenge.currencySymbol, "₸")
    }

    // MARK: - formatRaw

    func test_formatRaw_wholeNumber_returnsIntegerString() {
        XCTAssertEqual(CurrencyFormatter.formatRaw(5000), "5000")
    }

    func test_formatRaw_fractionalNumber_returnsDecimalString() {
        let result = CurrencyFormatter.formatRaw(1500.75)
        XCTAssertTrue(result.contains("1500.75"),
            "Fractional amount must include decimal, got: \(result)")
    }

    func test_formatRaw_zero_returnsZero() {
        XCTAssertEqual(CurrencyFormatter.formatRaw(0), "0")
    }

    func test_formatRaw_noCurrencySymbol() {
        let result = CurrencyFormatter.formatRaw(10_000)
        XCTAssertFalse(result.contains("₸"),
            "formatRaw must not contain ₸ symbol, got: \(result)")
    }
}
