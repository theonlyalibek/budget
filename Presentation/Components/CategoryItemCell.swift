import SwiftUI

/// Reusable category cell for the category grid in Add/Edit transaction views.
/// Works with both system and custom categories via CategoryItem.
struct CategoryItemCell: View {
    let item: CategoryItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: item.iconName)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(isSelected ? item.color : item.color.opacity(0.12))
                .foregroundStyle(isSelected ? .white : item.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.displayName)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}
