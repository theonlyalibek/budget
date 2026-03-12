import Foundation

/// Raw transaction data extracted from a bank statement PDF.
/// This is a plain value type — not a SwiftData model.
struct ParsedTransaction: Equatable, Sendable {
    let date: Date
    let amount: Double
    let merchant: String
    let isIncome: Bool
}
