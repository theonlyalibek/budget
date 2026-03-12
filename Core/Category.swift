import Foundation
import SwiftUI

enum Category: String, CaseIterable, Identifiable {
    case food = "food"
    case transport = "transport"
    case housing = "housing"
    case utilities = "utilities"
    case entertainment = "entertainment"
    case health = "health"
    case clothing = "clothing"
    case education = "education"
    case subscriptions = "subscriptions"
    case transfers = "transfers"
    case income = "income"
    case other = "other"

    var id: String { rawValue }

    var localizedKey: String {
        "category_\(rawValue)"
    }

    var iconName: String {
        switch self {
        case .food: "cart.fill"
        case .transport: "car.fill"
        case .housing: "house.fill"
        case .utilities: "bolt.fill"
        case .entertainment: "gamecontroller.fill"
        case .health: "heart.fill"
        case .clothing: "tshirt.fill"
        case .education: "book.fill"
        case .subscriptions: "repeat"
        case .transfers: "arrow.left.arrow.right"
        case .income: "banknote.fill"
        case .other: "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: .orange
        case .transport: .blue
        case .housing: .brown
        case .utilities: .yellow
        case .entertainment: .purple
        case .health: .red
        case .clothing: .pink
        case .education: .cyan
        case .subscriptions: .indigo
        case .transfers: .gray
        case .income: .green
        case .other: .secondary
        }
    }
}
