import SwiftUI

/// Filter sheet for History — Figma `Filters Sheet`.
struct HistoryFiltersSheet: View {
    @Binding var selectedCategories: Set<Category>
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var onApply: () -> Void
    var onReset: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var useDateRange = false
    @State private var localStart: Date = Calendar.current.date(
        byAdding: .month, value: -1, to: .now
    ) ?? .now
    @State private var localEnd: Date = .now

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
                    ForEach(Category.allCases.filter { $0 != .income }) { cat in
                        Button {
                            toggleCategory(cat)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: cat.iconName)
                                    .foregroundStyle(cat.color)
                                    .frame(width: 24)
                                Text(String(localized: String.LocalizationValue(cat.localizedKey)))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategories.contains(cat) {
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

    private func toggleCategory(_ cat: Category) {
        if selectedCategories.contains(cat) {
            selectedCategories.remove(cat)
        } else {
            selectedCategories.insert(cat)
        }
    }
}
