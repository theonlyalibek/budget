import Foundation

enum CurrencyFormatter {
    static let tenge: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "KZT"
        formatter.currencySymbol = "₸"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func format(_ amount: Double) -> String {
        tenge.string(from: NSNumber(value: amount)) ?? "\(Int(amount)) ₸"
    }

    /// Returns plain number string without currency symbol (for pre-filling text fields).
    static func formatRaw(_ amount: Double) -> String {
        if amount == amount.rounded() {
            return String(Int(amount))
        }
        return String(amount)
    }
}
