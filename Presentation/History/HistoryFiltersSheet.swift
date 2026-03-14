import SwiftUI

/// Filter sheet for History — Figma `Filters Sheet`.
/// Uses raw category keys (String) to support both system and custom categories.
struct HistoryFiltersSheet: View {
    @Binding var selectedCategories: Set<String>
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var customCategories: [CustomCategorySnapshot]
    var onApply: () -> Void
    var onReset: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var useDateRange = false
    @State private var localStart: Date = Calendar.current.date(
        byAdding: .month, value: -1, to: .now
    ) ?? .now
    @State private var localEnd: Date = .now

    /// All filterable categories (system minus income, plus custom).
    private var filterItems: [CategoryItem] {
        var items: [CategoryItem] = Category.allCases
            .filter { $0 != .income }
            .map { .system($0) }
        items.append(contentsOf: customCategories.map { .custom($0) })
        return items
    }

    var body: some View {
        NavigationStack {
            Form {
                // Date range
                Section(String(localized: "date_range")) {
                    Toggle(String(localized: "filter_by_date"), isOn: $useDateRange)

                    if useDateRange {
                        DatePicker(
                            String(localized: "from_date"),
                            selection: $localStart,
                            displayedComponents: .date
                        )
                        DatePicker(
                            String(localized: "to_date"),
                            selection: $localEnd,
                            displayedComponents: .date
                        )
                    }
                }

                // Category filter
                Section(String(localized: "categories_filter")) {
                    ForEach(filterItems) { item in
                        Button {
                            toggleCategory(item.storageKey)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: item.iconName)
                                    .foregroundStyle(item.color)
                                    .frame(width: 24)
                                Text(item.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategories.contains(item.storageKey) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "reset")) {
                        onReset()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "apply")) {
                        startDate = useDateRange ? localStart : nil
                        endDate = useDateRange ? localEnd : nil
                        onApply()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                useDateRange = startDate != nil
                if let s = startDate { localStart = s }
                if let e = endDate { localEnd = e }
            }
        }
    }

    private func toggleCategory(_ key: String) {
        if selectedCategories.contains(key) {
            selectedCategories.remove(key)
        } else {
            selectedCategories.insert(key)
        }
    }
}
