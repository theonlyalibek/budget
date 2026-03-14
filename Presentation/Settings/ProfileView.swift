import SwiftUI

/// Profile / Account screen — Figma `ProfileScreen`.
/// Shell placeholder for Step 2; full implementation in Step 3.
struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "profile_name_placeholder"))
                            .font(.title3.bold())
                        Text(String(localized: "profile_subtitle"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section(String(localized: "profile_accounts")) {
                Label("Kaspi Gold", systemImage: "creditcard.fill")
                Label {
                    HStack {
                        Text("Halyk Bank")
                        Spacer()
                        Text(String(localized: "coming_soon"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "creditcard")
                }
            }
        }
        .navigationTitle(String(localized: "profile_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
