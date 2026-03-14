import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var container: DIContainer
    @State private var showEraseConfirmation = false
    @State private var didErase = false

    var body: some View {
        NavigationStack {
            List {
                accountSection
                importSection
                subscriptionsSection
                categoriesSection
                notificationsSection
                appearanceSection
                dataSection
                aboutSection
            }
            .navigationTitle(String(localized: "tab_settings"))
            .confirmationDialog(
                String(localized: "erase_all_title"),
                isPresented: $showEraseConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "erase_all_confirm"), role: .destructive) {
                    eraseAllData()
                }
                Button(String(localized: "cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "erase_all_message"))
            }
            .overlay {
                if didErase { eraseToast }
            }
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        Section {
            NavigationLink {
                ProfileView()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "profile_name_placeholder"))
                            .font(.headline)
                        Text(String(localized: "profile_subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Import (moved from tab bar)

    private var importSection: some View {
        Section {
            NavigationLink {
                ImportView(
                    viewModel: ImportViewModel(
                        importUseCase: container.importStatementUseCase,
                        parser: container.kaspiParser
                    )
                )
            } label: {
                Label(String(localized: "import_statement"), systemImage: "doc.badge.plus")
            }
        }
    }

    // MARK: - Subscriptions

    private var subscriptionsSection: some View {
        Section {
            NavigationLink {
                SubscriptionsView(
                    viewModel: SubscriptionsViewModel(
                        repository: container.transactionRepository
                    )
                )
            } label: {
                Label(String(localized: "subscriptions_title"), systemImage: "repeat")
            }
        }
    }

    // MARK: - Categories

    private var categoriesSection: some View {
        Section {
            NavigationLink {
                CategoriesManagerView()
            } label: {
                Label(String(localized: "categories_title"), systemImage: "square.grid.2x2")
            }
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            NavigationLink {
                NotificationsSettingsView()
            } label: {
                Label(String(localized: "notifications_title"), systemImage: "bell.badge")
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section(String(localized: "appearance")) {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label(String(localized: "system_appearance"), systemImage: "paintbrush")
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section(String(localized: "data_and_backup")) {
            NavigationLink {
                ExportDataView()
            } label: {
                Label(String(localized: "export_title"), systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                showEraseConfirmation = true
            } label: {
                Label(String(localized: "erase_all_data"), systemImage: "trash")
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section(String(localized: "about")) {
            HStack {
                Text(String(localized: "app_version"))
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Actions

    private func eraseAllData() {
        do {
            try container.transactionRepository.deleteAll()
            didErase = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                didErase = false
            }
        } catch {
            // Silently fail for MVP
        }
    }

    // MARK: - Toast

    private var eraseToast: some View {
        VStack {
            Spacer()
            Label(String(localized: "data_erased"), systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: didErase)
    }
}
