import SwiftUI

struct AddTransactionView: View {

    @State private var viewModel: AddTransactionViewModel
    @State private var showSavedToast = false

    init(viewModel: AddTransactionViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                amountSection
                typeToggle
                categorySection
                detailsSection
            }
            .navigationTitle(String(localized: "tab_add"))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(String(localized: "done")) {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveButton
            }
            .overlay {
                if showSavedToast {
                    savedToast
                }
            }
            .onChange(of: viewModel.didSave) { _, saved in
                if saved {
                    showSavedToast = true
                    viewModel.didSave = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showSavedToast = false
                    }
                }
            }
        }
    }

    // MARK: - Amount

    private var amountSection: some View {
        Section {
            HStack {
                Text("₸")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.secondary)

                TextField("0", text: $viewModel.amountText)
                    .font(.largeTitle.bold())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Income / Expense Toggle

    private var typeToggle: some View {
        Section {
            Picker(String(localized: "transaction_type"), selection: $viewModel.isIncome) {
                Text(String(localized: "expense")).tag(false)
                Text(String(localized: "income_type")).tag(true)
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Category Grid

    private var categorySection: some View {
        Section(String(localized: "select_category")) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                spacing: 12
            ) {
                ForEach(expenseCategories, id: \.self) { cat in
                    CategoryCell(
                        category: cat,
                        isSelected: viewModel.category == cat
                    )
                    .onTapGesture {
                        viewModel.category = cat
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    /// Categories relevant for manual entry (exclude income/transfers).
    private var expenseCategories: [Category] {
        Category.allCases.filter { $0 != .income && $0 != .transfers }
    }

    // MARK: - Details

    private var detailsSection: some View {
        Section {
            DatePicker(
                String(localized: "date"),
                selection: $viewModel.date,
                displayedComponents: .date
            )

            TextField(
                String(localized: "note"),
                text: $viewModel.note,
                axis: .vertical
            )
            .lineLimit(1...3)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            viewModel.save()
        } label: {
            Group {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Text(saveButtonTitle)
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.canSave)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private var saveButtonTitle: String {
        if viewModel.parsedAmount > 0 {
            let formatted = CurrencyFormatter.format(viewModel.parsedAmount)
            return String(localized: "save") + " \(formatted)"
        }
        return String(localized: "save")
    }

    // MARK: - Toast

    private var savedToast: some View {
        VStack {
            Spacer()
            Label(String(localized: "transaction_saved"), systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: showSavedToast)
    }
}

// MARK: - Category Cell

private struct CategoryCell: View {
    let category: Category
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: category.iconName)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(isSelected ? category.color : category.color.opacity(0.12))
                .foregroundStyle(isSelected ? .white : category.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(String(localized: String.LocalizationValue(category.localizedKey)))
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
    }
}
