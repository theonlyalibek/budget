import SwiftUI

/// Financial literacy lessons — premium feature placeholder (Step 4).
/// Replace with real lesson list + content in a future step.
struct FinancialLessonsPlaceholderView: View {
    var body: some View {
        EmptyStateBlock(
            systemImage: "book.fill",
            title: String(localized: "feature_financial_lessons_name"),
            description: String(localized: "lessons_coming_description"),
            actionTitle: nil,
            action: nil
        )
        .navigationTitle(String(localized: "feature_financial_lessons_name"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
