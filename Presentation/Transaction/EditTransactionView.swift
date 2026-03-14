import SwiftUI

struct EditTransactionView: View {

    @State private var viewModel: EditTransactionViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: EditTransactionViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            amountSection
            typeToggle
            categorySection
            detailsSection
            deleteSection
        }
        .navigationTitle(String(localized: "edit_transaction_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(String(localized: "cancel")) {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(String(localized: "done")) {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "save")) {
                    viewModel.save()
                }
                .fontWeight(.semibold)
                .disabled(!viewModel.canSave || !viewModel.hasChanges)
            }
        }
        .alert(
            String(localized: "error"),
            isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "ok")) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .confirmationDialog(
            String(localized: "delete_transaction_confirm"),
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "delete"), role: .destructive) {
                viewModel.deleteTransaction()
            }
            Button(String(localized: "cancel"), role: .cancel) { }
        }
        .onChange(of: viewModel.didSave) { _, saved in
            if saved { dismiss() }
        }
        .onChange(of: viewModel.didDelete) { _, deleted in
            if deleted { dismiss() }
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
                ForEach(viewModel.expenseCategories) { item in
                    CategoryItemCell(
                        item: item,
                        isSelected: viewModel.selectedCategory == item
                    )
                    .onTapGesture {
                        viewModel.selectCategory(item)
                    }
                }
            }
            .padding(.vertical, 4)

            if !viewModel.selectedCategory.subcategoryItems.isEmpty {
                subcategoryPicker
            }
        }
    }

    private var subcategoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.selectedCategory.subcategoryItems) { sub in
                    let isSelected = viewModel.selectedSubcategory == sub
                    Text(sub.displayName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected
                            ? viewModel.selectedCategory.color
                            : viewModel.selectedCategory.color.opacity(0.12))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            viewModel.toggleSubcategory(sub)
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        Section {
            DatePicker(
                String(localized: "date"),
                selection: $viewModel.date,
                displayedComponents: [.date, .hourAndMinute]
            )

            TextField(
                String(localized: "note"),
                text: $viewModel.note,
                axis: .vertical
            )
            .lineLimit(1...3)

            Toggle(String(localized: "mark_as_subscription"), isOn: $viewModel.isSubscription)
        }
    }

    // MARK: - Delete

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.confirmDelete()
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isDeleting {
                        ProgressView()
                    } else {
                        Label(String(localized: "delete_transaction"), systemImage: "trash")
                    }
                    Spacer()
                }
            }
        }
    }
}
