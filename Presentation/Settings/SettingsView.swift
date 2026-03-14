import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var container: DIContainer
    @Environment(LocalSubscriptionService.self) private var subscriptionService
    @State private var showEraseConfirmation = false
    @State private var didErase = false

    var body: some View {
        NavigationStack {
            List {
                accountSection
                premiumSection
                importSection
                subscriptionsSection
                premiumFeaturesSection
                categoriesSection
                notificationsSection
                appearanceSection
                dataSection
                aboutSection
                #if DEBUG
                debugSection
                #endif
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

    // MARK: - Premium Status

    private var premiumSection: some View {
        Section {
            if subscriptionService.isSubscribed {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "premium_active_title"))
                            .font(.subheadline.weight(.semibold))
                        Text(String(localized: "premium_active_subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            } else {
                Button {
                    // PaywallView can show any feature as entry point; aiCoach is primary
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(String(localized: "premium_cta_title"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                PremiumBadge()
                            }
                            Text(String(localized: "premium_cta_subtitle"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
                // NavigationLink to paywall would go here — using Button for now
                // because PaywallView is presented as sheet, not push
                .buttonStyle(.plain)
                .background(
                    NavigationLink("", destination: PaywallView(feature: .aiCoach))
                        .opacity(0)
                )
            }
        }
    }

    // MARK: - Premium Features (gated rows)

    private var premiumFeaturesSection: some View {
        Section(String(localized: "premium_features_section")) {
            // Financial literacy — gated
            FeatureGate(feature: .financialLessons) {
                // Placeholder: replace with NavigationLink to real LessonsView in future
                NavigationLink {
                    FinancialLessonsPlaceholderView()
                } label: {
                    Label(
                        String(localized: "feature_financial_lessons_name"),
                        systemImage: PremiumFeature.financialLessons.iconName
                    )
                }
            }

            // Advanced import — gated
            FeatureGate(feature: .advancedImport) {
                NavigationLink {
                    AdvancedImportPlaceholderView()
                } label: {
                    Label(
                        String(localized: "feature_advanced_import_name"),
                        systemImage: PremiumFeature.advancedImport.iconName
                    )
                }
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

    // MARK: - Debug (non-release only)

    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Premium subscription")
                        .font(.subheadline)
                    Text(subscriptionService.isSubscribed ? "Active (local)" : "Inactive")
                        .font(.caption)
                        .foregroundStyle(subscriptionService.isSubscribed ? .green : .secondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { subscriptionService.isSubscribed },
                    set: { _ in subscriptionService.toggleDebugSubscription() }
                ))
            }
        }
    }
    #endif

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
