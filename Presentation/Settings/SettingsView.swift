import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var container: DIContainer
    @State private var showEraseConfirmation = false
    @State private var didErase = false

    var body: some View {
        NavigationStack {
            List {
                subscriptionsSection
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
                if didErase {
                    eraseToast
                }
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

            Label {
                Text(String(localized: "appearance_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section(String(localized: "data_and_backup")) {
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
            // Silently fail for MVP — could show alert
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
