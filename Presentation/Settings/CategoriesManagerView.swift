import SwiftUI

/// Category management screen — Figma `CategoriesManager`.
/// Shows built-in categories (read-only) and custom categories with full CRUD.
struct CategoriesManagerView: View {
    @State private var viewModel: CategoriesManagerViewModel

    init(viewModel: CategoriesManagerViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            // Custom categories section
            Section {
                if viewModel.customCategories.isEmpty {
                    Text(String(localized: "no_custom_categories"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.customCategories, id: \.id) { category in
                        customCategoryRow(category)
                    }
                }

                Button {
                    viewModel.prepareAddCategory()
                } label: {
                    Label(String(localized: "add_category"), systemImage: "plus.circle.fill")
                }
            } header: {
                Text(String(localized: "custom_categories"))
            }

            // Built-in categories section (read-only)
            Section(String(localized: "builtin_categories")) {
                ForEach(Category.allCases) { cat in
                    DisclosureGroup {
                        if cat.subcategories.isEmpty {
                            Text(String(localized: "no_subcategories"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(cat.subcategories, id: \.self) { sub in
                                HStack(spacing: 8) {
                                    Image(systemName: "tag.fill")
                                        .font(.caption)
                                        .foregroundStyle(cat.color.opacity(0.6))
                                    Text(Category.localizedSubcategory(sub))
                                        .font(.subheadline)
                                }
                                .padding(.leading, 8)
                            }
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: cat.iconName)
                                .font(.title3)
                                .foregroundStyle(cat.color)
                                .frame(width: 32, height: 32)
                                .background(cat.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: String.LocalizationValue(cat.localizedKey)))
                                    .font(.body)
                                if !cat.subcategories.isEmpty {
                                    Text("\(cat.subcategories.count)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
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
        .onAppear { viewModel.loadCategories() }
        .sheet(isPresented: $viewModel.showAddCategory) {
            categoryFormSheet
        }
        .sheet(isPresented: $viewModel.showAddSubcategory) {
            subcategoryFormSheet
        }
        .confirmationDialog(
            String(localized: "delete_category_confirm"),
            isPresented: .init(
                get: { viewModel.categoryToDelete != nil },
                set: { if !$0 { viewModel.categoryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "delete"), role: .destructive) {
                viewModel.deleteCategory()
            }
            Button(String(localized: "cancel"), role: .cancel) {
                viewModel.categoryToDelete = nil
            }
        } message: {
            Text(String(localized: "delete_category_message"))
        }
        .confirmationDialog(
            String(localized: "delete_subcategory_confirm"),
            isPresented: .init(
                get: { viewModel.subcategoryToDelete != nil },
                set: { if !$0 { viewModel.subcategoryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "delete"), role: .destructive) {
                viewModel.deleteSubcategory()
            }
            Button(String(localized: "cancel"), role: .cancel) {
                viewModel.subcategoryToDelete = nil
            }
        }
    }

    // MARK: - Custom Category Row

    private func customCategoryRow(_ category: CustomCategory) -> some View {
        DisclosureGroup {
            // Subcategories
            ForEach(category.subcategories.sorted(by: { $0.createdAt < $1.createdAt }), id: \.id) { sub in
                HStack(spacing: 8) {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundStyle(Color(hex: category.colorHex).opacity(0.6))
                    Text(sub.name)
                        .font(.subheadline)
                        .strikethrough(!sub.isActive, color: .secondary)

                    Spacer()

                    Menu {
                        Button {
                            viewModel.prepareEditSubcategory(sub)
                        } label: {
                            Label(String(localized: "edit"), systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            viewModel.confirmDeleteSubcategory(sub)
                        } label: {
                            Label(String(localized: "delete"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.leading, 8)
            }

            // Add subcategory button
            Button {
                viewModel.prepareAddSubcategory(parent: category)
            } label: {
                Label(String(localized: "add_subcategory"), systemImage: "plus")
                    .font(.subheadline)
            }
            .padding(.leading, 8)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.iconName)
                    .font(.title3)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .frame(width: 32, height: 32)
                    .background(Color(hex: category.colorHex).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.body)
                        .strikethrough(!category.isActive, color: .secondary)
                    if !category.subcategories.isEmpty {
                        Text("\(category.subcategories.count)")

                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button {
                        viewModel.prepareEditCategory(category)
                    } label: {
                        Label(String(localized: "edit"), systemImage: "pencil")
                    }

                    Button {
                        viewModel.toggleCategoryActive(category)
                    } label: {
                        Label(
                            category.isActive
                                ? String(localized: "deactivate")
                                : String(localized: "activate"),
                            systemImage: category.isActive ? "eye.slash" : "eye"
                        )
                    }

                    Button(role: .destructive) {
                        viewModel.confirmDeleteCategory(category)
                    } label: {
                        Label(String(localized: "delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Category Form Sheet

    private var categoryFormSheet: some View {
        NavigationStack {
            Form {
                Section(String(localized: "category_name")) {
                    TextField(String(localized: "category_name_placeholder"), text: $viewModel.categoryName)
                }

                Section(String(localized: "icon")) {
                    iconPicker
                }

                Section(String(localized: "color")) {
                    colorPicker
                }
            }
            .navigationTitle(
                viewModel.editingCategory != nil
                    ? String(localized: "edit_category")
                    : String(localized: "add_category")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "cancel")) {
                        viewModel.showAddCategory = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "save")) {
                        viewModel.saveCategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Icon Picker

    private var iconPicker: some View {
        let icons = [
            "folder.fill", "star.fill", "heart.fill", "bag.fill", "cart.fill",
            "house.fill", "car.fill", "airplane", "gift.fill", "creditcard.fill",
            "cup.and.saucer.fill", "fork.knife", "dumbbell.fill", "pawprint.fill",
            "leaf.fill", "drop.fill", "flame.fill", "wrench.fill", "paintbrush.fill",
            "music.note", "book.fill", "graduationcap.fill", "stethoscope",
            "gamecontroller.fill", "tv.fill", "iphone", "desktopcomputer"
        ]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(icons, id: \.self) { icon in
                Button {
                    viewModel.categoryIcon = icon
                } label: {
                    Image(systemName: icon)
                        .font(.title3)
                        .frame(width: 40, height: 40)
                        .background(
                            viewModel.categoryIcon == icon
                                ? Color(hex: viewModel.categoryColorHex)
                                : Color(hex: viewModel.categoryColorHex).opacity(0.12)
                        )
                        .foregroundStyle(
                            viewModel.categoryIcon == icon
                                ? .white
                                : Color(hex: viewModel.categoryColorHex)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Color Picker

    private var colorPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(CategoryColorPreset.allCases) { preset in
                Button {
                    viewModel.categoryColorHex = preset.rawValue
                } label: {
                    Circle()
                        .fill(preset.color)
                        .frame(width: 36, height: 36)
                        .overlay {
                            if viewModel.categoryColorHex == preset.rawValue {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Subcategory Form Sheet

    private var subcategoryFormSheet: some View {
        NavigationStack {
            Form {
                Section(String(localized: "subcategory_name")) {
                    TextField(
                        String(localized: "subcategory_name_placeholder"),
                        text: $viewModel.subcategoryName
                    )
                }
            }
            .navigationTitle(
                viewModel.editingSubcategory != nil
                    ? String(localized: "edit_subcategory")
                    : String(localized: "add_subcategory")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(String(localized: "cancel")) {
                        viewModel.showAddSubcategory = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "save")) {
                        viewModel.saveSubcategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(viewModel.subcategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
