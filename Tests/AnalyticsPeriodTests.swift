import XCTest
@testable import budget

final class AnalyticsPeriodTests: XCTestCase {

    private let now = Date.now
    private let calendar = Calendar.current

    // MARK: - Invariants

    func test_allPeriods_startIsBeforeEnd() {
        for period in AnalyticsPeriod.allCases {
            let range = period.dateRange(from: now)
            XCTAssertLessThan(range.start, range.end,
                "\(period.rawValue): start must be strictly before end")
        }
    }

    func test_allPeriods_endApproximatesNow() {
        let tolerance: TimeInterval = 5  // seconds
        for period in AnalyticsPeriod.allCases {
            let range = period.dateRange(from: now)
            XCTAssertEqual(range.end.timeIntervalSince1970,
                           now.timeIntervalSince1970,
                           accuracy: tolerance,
                "\(period.rawValue): end must equal the reference 'now'")
        }
    }

    // MARK: - Week

    func test_week_rangeIsApproximatelySevenDays() {
        let range = AnalyticsPeriod.week.dateRange(from: now)
        let days = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? -1
        XCTAssertEqual(days, 7,
            "Week period must span 7 days, got \(days)")
    }

    func test_week_localizedKeyExists() {
        XCTAssertEqual(AnalyticsPeriod.week.localizedKey, "period_week")
    }

    // MARK: - Month

    func test_month_rangeIsApproximatelyThirtyDays() {
        let range = AnalyticsPeriod.month.dateRange(from: now)
        let days = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? -1
        // A "month back" spans 28–31 days depending on the calendar month.
        XCTAssertTrue((28...31).contains(days),
            "Month period must span 28–31 days, got \(days)")
    }

    func test_month_localizedKeyExists() {
        XCTAssertEqual(AnalyticsPeriod.month.localizedKey, "period_month")
    }

    // MARK: - Year

    func test_year_rangeIsApproximately365Days() {
        let range = AnalyticsPeriod.year.dateRange(from: now)
        let days = calendar.dateComponents([.day], from: range.start, to: range.end).day ?? -1
        // 365 for regular years, 366 for leap years.
        XCTAssertTrue((365...366).contains(days),
            "Year period must span 365–366 days, got \(days)")
    }

    func test_year_localizedKeyExists() {
        XCTAssertEqual(AnalyticsPeriod.year.localizedKey, "period_year")
    }

    // MARK: - Identifiable

    func test_allCases_haveUniqueIDs() {
        let ids = AnalyticsPeriod.allCases.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count,
            "All AnalyticsPeriod cases must have unique IDs")
    }

    // MARK: - Determinism

    func test_sameNow_producesSameRange() {
        let ref = Date(timeIntervalSince1970: 1_700_000_000)
        let r1 = AnalyticsPeriod.month.dateRange(from: ref)
        let r2 = AnalyticsPeriod.month.dateRange(from: ref)
        XCTAssertEqual(r1.start, r2.start)
        XCTAssertEqual(r1.end, r2.end)
    }
}
