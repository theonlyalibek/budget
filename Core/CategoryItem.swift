import SwiftUI

/// Lightweight snapshot of a CustomCategory for value-type usage in views.
struct CustomCategorySnapshot: Hashable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let iconName: String
    let colorHex: String
    let subcategories: [CustomSubcategorySnapshot]

    var color: Color { Color(hex: colorHex) }
    var storageKey: String { "custom:\(id.uuidString)" }
}

/// Lightweight snapshot of a CustomSubcategory.
struct CustomSubcategorySnapshot: Hashable, Identifiable, Sendable {
    let id: UUID
    let name: String

    var storageKey: String { "custom_sub:\(id.uuidString)" }
}

/// Unified category type wrapping either a built-in enum or a custom user category.
enum CategoryItem: Hashable, Identifiable {
    case system(Category)
    case custom(CustomCategorySnapshot)

    var id: String {
        switch self {
        case .system(let cat): cat.rawValue
        case .custom(let snap): snap.storageKey
        }
    }

    /// The string stored in Transaction.category
    var storageKey: String { id }

    var displayName: String {
        switch self {
        case .system(let cat):
            String(localized: String.LocalizationValue(cat.localizedKey))
        case .custom(let snap):
            snap.name
        }
    }

    var iconName: String {
        switch self {
        case .system(let cat): cat.iconName
        case .custom(let snap): snap.iconName
        }
    }

    var color: Color {
        switch self {
        case .system(let cat): cat.color
        case .custom(let snap): snap.color
        }
    }

    var subcategoryItems: [SubcategoryItem] {
        switch self {
        case .system(let cat):
            cat.subcategories.map { .system(key: $0, parentCategory: cat) }
        case .custom(let snap):
            snap.subcategories.map { .custom($0) }
        }
    }

    /// Resolve a stored category string into a CategoryItem.
    static func from(
        storedValue: String,
        customCategories: [CustomCategorySnapshot]
    ) -> CategoryItem {
        if storedValue.hasPrefix("custom:") {
            let uuidString = String(storedValue.dropFirst("custom:".count))
            if let snap = customCategories.first(where: { $0.id.uuidString == uuidString }) {
                return .custom(snap)
            }
            return .system(.other) // Deleted custom category fallback
        }
        if let cat = Category(rawValue: storedValue) {
            return .system(cat)
        }
        return .system(.other)
    }
}

/// Unified subcategory type.
enum SubcategoryItem: Hashable, Identifiable {
    case system(key: String, parentCategory: Category)
    case custom(CustomSubcategorySnapshot)

    var id: String {
        switch self {
        case .system(let key, _): key
        case .custom(let snap): snap.storageKey
        }
    }

    /// The string stored in Transaction.subcategory
    var storageKey: String { id }

    var displayName: String {
        switch self {
        case .system(let key, _):
            Category.localizedSubcategory(key)
        case .custom(let snap):
            snap.name
        }
    }
}

// MARK: - Snapshot Factories

extension CustomCategory {
    /// Creates a value-type snapshot for use in views.
    var snapshot: CustomCategorySnapshot {
        CustomCategorySnapshot(
            id: id,
            name: name,
            iconName: iconName,
            colorHex: colorHex,
            subcategories: (subcategories).compactMap { sub in
                guard sub.isActive else { return nil }
                return CustomSubcategorySnapshot(id: sub.id, name: sub.name)
            }
        )
    }
}
