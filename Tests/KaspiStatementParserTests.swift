import XCTest
@testable import budget

final class KaspiStatementParserTests: XCTestCase {

    private var parser: KaspiStatementParser!

    override func setUp() {
        super.setUp()
        parser = KaspiStatementParser()
    }

    override func tearDown() {
        parser = nil
        super.tearDown()
    }

    // MARK: - canParse

    func testCanParseReturnsTrueForKaspiText() {
        XCTAssertTrue(parser.canParse("Выписка Kaspi Bank за март 2025"))
    }

    func testCanParseReturnsTrueForCyrillicKaspi() {
        XCTAssertTrue(parser.canParse("Каспи банк выписка"))
    }

    func testCanParseReturnsFalseForUnrelatedText() {
        XCTAssertFalse(parser.canParse("Halyk Bank statement"))
    }

    // MARK: - Error handling

    func testParseEmptyTextReturnsError() {
        let result = parser.parse("")
        XCTAssertEqual(result, .failure(.emptyText))
    }

    func testParseWhitespaceOnlyReturnsError() {
        let result = parser.parse("   \n  \n  ")
        XCTAssertEqual(result, .failure(.emptyText))
    }

    func testParseNonKaspiTextReturnsUnsupportedFormat() {
        let result = parser.parse("Halyk Bank statement for 2025")
        XCTAssertEqual(result, .failure(.unsupportedFormat))
    }

    func testParseKaspiHeaderOnlyReturnsNoTransactions() {
        let text = """
        АО «Kaspi Bank», БИК CASPKZKA, www.kaspi.kz
        ВЫПИСКА
        по Kaspi Gold за период с 11.03.26 по 12.03.26
        Дата Сумма Операция Детали
        """
        let result = parser.parse(text)
        XCTAssertEqual(result, .failure(.noTransactionsFound))
    }

    // MARK: - Single line parsing

    func testParsePurchaseLine() {
        let text = """
        АО «Kaspi Bank»
        12.03.26 - 3 330,00 ₸ Покупка fresh market
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 1)

        let t = transactions[0]
        XCTAssertEqual(t.amount, 3330.0)
        XCTAssertEqual(t.merchant, "fresh market")
        XCTAssertFalse(t.isIncome)
    }

    func testParseIncomeLine() {
        let text = """
        Kaspi Gold выписка
        12.03.26 + 10 000,00 ₸ Пополнение Мақсат М.
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 1)

        let t = transactions[0]
        XCTAssertEqual(t.amount, 10000.0)
        XCTAssertEqual(t.merchant, "Мақсат М.")
        XCTAssertTrue(t.isIncome)
    }

    func testParseTransferLine() {
        let text = """
        Kaspi выписка
        11.03.26 - 2 050,00 ₸ Перевод Дəурен Ж.
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 1)

        let t = transactions[0]
        XCTAssertEqual(t.amount, 2050.0)
        XCTAssertEqual(t.merchant, "Дəурен Ж.")
        XCTAssertFalse(t.isIncome)
    }

    func testParseSmallAmount() {
        let text = """
        Kaspi Bank
        11.03.26 - 1,66 ₸ Покупка Алматы Паркинг. Оплата парковок Алматы
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions[0].amount, 1.66)
    }

    func testParseFractionalAmount() {
        let text = """
        Kaspi Bank
        12.03.26 - 6 610,84 ₸ Покупка FACEBK *U9G23FDR62
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions[0].amount, 6610.84, accuracy: 0.01)
        XCTAssertEqual(transactions[0].merchant, "FACEBK *U9G23FDR62")
    }

    // MARK: - Multi-line (full statement excerpt)

    func testParseMultipleTransactions() {
        let text = """
        АО «Kaspi Bank», БИК CASPKZKA, www.kaspi.kz
        ВЫПИСКА
        по Kaspi Gold за период с 11.03.26 по 12.03.26
        Дата Сумма Операция Детали
        12.03.26 - 50,00 ₸ Покупка Алматы Паркинг. Оплата парковок Алматы
        12.03.26 - 3 330,00 ₸ Покупка fresh market
        12.03.26 + 10 000,00 ₸ Пополнение Мақсат М.
        11.03.26 - 6 604,00 ₸ Покупка WOLT.COM
        11.03.26 - 2 050,00 ₸ Перевод Дəурен Ж.
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        XCTAssertEqual(transactions.count, 5)

        // Verify income count
        let incomes = transactions.filter(\.isIncome)
        XCTAssertEqual(incomes.count, 1)

        // Verify total expense amount (50 + 3330 + 6604 + 2050 = 12034)
        let expenseTotal = transactions
            .filter { !$0.isIncome }
            .reduce(0.0) { $0 + $1.amount }
        XCTAssertEqual(expenseTotal, 12034.0, accuracy: 0.01)
    }

    // MARK: - Lines that should be skipped

    func testForeignCurrencyLineIsSkipped() {
        let text = """
        Kaspi Bank
        12.03.26 - 6 610,84 ₸ Покупка FACEBK *U9G23FDR62
        (- 13,29 USD)
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        // Only 1 transaction, the USD continuation line is ignored
        XCTAssertEqual(transactions.count, 1)
    }

    func testSummaryLinesAreSkipped() {
        let text = """
        АО «Kaspi Bank», БИК CASPKZKA
        Доступно на 11.03.26 + 97 808,85 ₸
        Пополнения + 10 000,00 ₸
        Покупки - 26 959,71 ₸
        11.03.26 - 2 620,00 ₸ Покупка ZYP ZYP
        """
        guard case .success(let transactions) = parser.parse(text) else {
            XCTFail("Expected successful parse")
            return
        }
        // Only the actual transaction line, not the summary lines
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions[0].merchant, "ZYP ZYP")
    }
}
