import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Double
    var date: Date
    var category: String
    var subcategory: String
    var note: String
    var isSubscription: Bool
    var isIncome: Bool

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = .now,
        category: String = "",
        subcategory: String = "",
        note: String = "",
        isSubscription: Bool = false,
        isIncome: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.category = category
        self.subcategory = subcategory
        self.note = note
        self.isSubscription = isSubscription
        self.isIncome = isIncome
    }
}
