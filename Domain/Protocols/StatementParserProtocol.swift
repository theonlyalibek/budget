import Foundation

/// Errors that can occur during statement parsing.
enum StatementParserError: Error, Equatable {
    case emptyText
    case unsupportedFormat
    case noTransactionsFound
}

/// Parses raw text extracted from a bank statement PDF
/// and returns an array of parsed transactions.
protocol StatementParserProtocol: Sendable {
    /// The bank name this parser handles (e.g. "Kaspi", "Halyk").
    var bankName: String { get }

    /// Returns true if this parser can handle the given text.
    func canParse(_ text: String) -> Bool

    /// Parse the raw PDF text into structured transactions.
    /// Returns an empty array — never crashes — if parsing fails.
    func parse(_ text: String) -> Result<[ParsedTransaction], StatementParserError>
}
