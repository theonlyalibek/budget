import Foundation

final class KaspiStatementParser: StatementParserProtocol {

    let bankName = "Kaspi"

    // MARK: - Regex

    /// Matches a Kaspi Gold transaction line:
    ///   DD.MM.YY  [+-]  X XXX,XX ₸  OperationType  Description
    ///
    /// Groups:
    ///   1 — date        (e.g. "12.03.26")
    ///   2 — sign        ("+" or "-")
    ///   3 — amount      (e.g. "6 610,84")
    ///   4 — operation   ("Покупка", "Пополнение", "Перевод", "Снятие", "Разное")
    ///   5 — description (e.g. "WOLT.COM")
    private static let linePattern: String =
        #"(\d{2}\.\d{2}\.\d{2})\s+([+-])\s+([\d\s]+,\d{2})\s*₸\s+(Покупка|Пополнение|Перевод|Снятие|Разное)\s+(.+)"#

    private let lineRegex: NSRegularExpression? = {
        try? NSRegularExpression(pattern: linePattern, options: [])
    }()

    // MARK: - Date Formatter

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        formatter.locale = Locale(identifier: "ru_KZ")
        // Ensure 2-digit year "26" maps to 2026, not 1926
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Almaty") ?? .current
        formatter.calendar = calendar
        formatter.defaultDate = nil
        return formatter
    }()

    // MARK: - Identification

    func canParse(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return lowered.contains("kaspi") || lowered.contains("каспи")
    }

    // MARK: - Parsing

    func parse(_ text: String) -> Result<[ParsedTransaction], StatementParserError> {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.emptyText)
        }

        guard canParse(text) else {
            return .failure(.unsupportedFormat)
        }

        let lines = text.components(separatedBy: .newlines)
        var transactions: [ParsedTransaction] = []

        for line in lines {
            guard let parsed = parseLine(line) else { continue }
            transactions.append(parsed)
        }

        if transactions.isEmpty {
            return .failure(.noTransactionsFound)
        }

        return .success(transactions)
    }

    // MARK: - Line Parsing

    private func parseLine(_ line: String) -> ParsedTransaction? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        guard let regex = lineRegex else { return nil }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        guard let match = regex.firstMatch(in: trimmed, options: [], range: range),
              match.numberOfRanges == 6 else {
            return nil
        }

        // Extract capture groups safely
        guard let dateStr = substring(from: match, at: 1, in: trimmed),
              let sign = substring(from: match, at: 2, in: trimmed),
              let amountStr = substring(from: match, at: 3, in: trimmed),
              // group 4 = operation type (not stored separately, but validated by regex)
              let description = substring(from: match, at: 5, in: trimmed) else {
            return nil
        }

        guard let date = parseDate(dateStr) else { return nil }
        guard let amount = parseAmount(amountStr) else { return nil }

        let isIncome = sign == "+"
        let merchant = description.trimmingCharacters(in: .whitespaces)

        return ParsedTransaction(
            date: date,
            amount: amount,
            merchant: merchant,
            isIncome: isIncome
        )
    }

    // MARK: - Helpers

    /// Safely extracts a substring from an NSTextCheckingResult capture group.
    private func substring(
        from match: NSTextCheckingResult,
        at index: Int,
        in text: String
    ) -> String? {
        guard index < match.numberOfRanges else { return nil }
        let nsRange = match.range(at: index)
        guard nsRange.location != NSNotFound,
              let range = Range(nsRange, in: text) else {
            return nil
        }
        return String(text[range])
    }

    private func parseDate(_ string: String) -> Date? {
        dateFormatter.date(from: string)
    }

    /// Strips spaces (thousand separators) and converts comma decimal to dot.
    private func parseAmount(_ string: String) -> Double? {
        let cleaned = string
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned)
    }
}
