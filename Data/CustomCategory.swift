import Foundation
import SwiftData

@Model
final class CustomCategory {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var isActive: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CustomSubcategory.parentCategory)
    var subcategories: [CustomSubcategory]

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "folder.fill",
        colorHex: String = "007AFF",
        isActive: Bool = true,
        createdAt: Date = .now,
        subcategories: [CustomSubcategory] = []
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.isActive = isActive
        self.createdAt = createdAt
        self.subcategories = subcategories
    }

    /// The string key stored in Transaction.category
    var storageKey: String {
        "custom:\(id.uuidString)"
    }
}
