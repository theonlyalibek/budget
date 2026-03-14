import SwiftUI

/// Category management screen — Figma `CategoriesManager`.
/// Shows all built-in categories; user-defined rules shown inline.
struct CategoriesManagerView: View {
    var body: some View {
        List {
            Section(String(localized: "builtin_categories")) {
                ForEach(Category.allCases) { cat in
                    HStack(spacing: 12) {
                        Image(systemName: cat.iconName)
                            .font(.title3)
                            .foregroundStyle(cat.color)
                            .frame(width: 32, height: 32)
                            .background(cat.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(String(localized: String.LocalizationValue(cat.localizedKey)))
                            .font(.body)
                    }
                }
            }

            Section {
                Text(String(localized: "categories_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "categories_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
