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
}
