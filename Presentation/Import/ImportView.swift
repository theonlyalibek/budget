import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {

    @State private var viewModel: ImportViewModel
    @State private var showFilePicker = false
    @State private var showSavedToast = false

    init(viewModel: ImportViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.hasPreview {
                    previewList
                } else {
                    emptyState
                }
            }
            .navigationTitle(String(localized: "tab_import"))
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.pdf],
                allowsMultipleSelection: false
            ) { result in
                handlePickerResult(result)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
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

    // MARK: - Empty State (File Picker Trigger)

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(String(localized: "import_pdf"))
                    .font(.title2.bold())

                Text(String(localized: "import_description"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button {
                showFilePicker = true
            } label: {
                Label(String(localized: "select_pdf"), systemImage: "doc.badge.plus")
                    .font(.headline)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 32)
            }
            .buttonStyle(.borderedProminent)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }

    // MARK: - Preview List

    private var previewList: some View {
        List {
            // Summary header
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Label(
                        String(localized: "parsed_transactions \(viewModel.transactionCount)"),
                        systemImage: "checkmark.circle.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(.green)

                    if viewModel.duplicatesSkipped > 0 {
                        Label(
                            String(localized: "duplicates_skipped \(viewModel.duplicatesSkipped)"),
                            systemImage: "arrow.triangle.2.circlepath"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }
                }
                .padding(.vertical, 4)
            }

            // Transaction rows
            Section(String(localized: "review_transactions")) {
                ForEach($viewModel.previewTransactions, id: \.id) { $transaction in
                    ImportTransactionRow(transaction: $transaction)
                }
            }

            // Error
            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "cancel")) {
                    viewModel.clearPreview()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showFilePicker = true
                } label: {
                    Image(systemName: "doc.badge.plus")
                }
            }
        }
    }

    // MARK: - Bottom Save Bar

    private var bottomBar: some View {
        VStack(spacing: 8) {
            Divider()
            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: "total_expenses"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(viewModel.previewTotal))
                        .font(.headline)
                }

                Spacer()

                Button {
                    viewModel.saveTransactions()
                } label: {
                    Text(String(localized: "save_transactions \(viewModel.transactionCount)"))
                        .font(.headline)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(.bar)
    }

    // MARK: - Helpers

    private func handlePickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            viewModel.handleFile(at: url)
        case .failure(let error):
            viewModel.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toast

    private var savedToast: some View {
        VStack {
            Spacer()
            Label(String(localized: "import_success"), systemImage: "checkmark.circle.fill")
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

// MARK: - Import Transaction Row

private struct ImportTransactionRow: View {
    @Binding var transaction: ImportedTransaction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top: merchant + amount
            HStack {
                Text(transaction.merchant)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Spacer()

                Text(formattedAmount)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.isIncome ? .green : .primary)
            }

            // Bottom: date + category picker
            HStack {
                Text(transaction.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Picker("", selection: $transaction.category) {
                    ForEach(Category.allCases) { cat in
                        Label(
                            String(localized: String.LocalizationValue(cat.localizedKey)),
                            systemImage: cat.iconName
                        )
                        .tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .tint(transaction.category.color)
            }
        }
        .padding(.vertical, 2)
    }

    private var formattedAmount: String {
        let prefix = transaction.isIncome ? "+ " : "- "
        return prefix + CurrencyFormatter.format(transaction.amount)
    }
}
