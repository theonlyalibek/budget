import Foundation
import SwiftData

@Model
final class CategoryRule {
    var id: UUID
    var keyword: String
    var categoryName: String

    init(
        id: UUID = UUID(),
        keyword: String,
        categoryName: String
    ) {
        self.id = id
        self.keyword = keyword
        self.categoryName = categoryName
    }
}
