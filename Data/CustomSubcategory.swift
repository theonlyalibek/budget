import Foundation
import SwiftData

@Model
final class CustomSubcategory {
    var id: UUID
    var name: String
    var isActive: Bool
    var createdAt: Date
    var parentCategory: CustomCategory?

    init(
        id: UUID = UUID(),
        name: String,
        isActive: Bool = true,
        createdAt: Date = .now,
        parentCategory: CustomCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.isActive = isActive
        self.createdAt = createdAt
        self.parentCategory = parentCategory
    }

    /// The string key stored in Transaction.subcategory
    var storageKey: String {
        "custom_sub:\(id.uuidString)"
    }
}
