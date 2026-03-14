import SwiftUI

/// Notifications settings — Figma `NotificationsScreen`.
/// Shell placeholder; full implementation deferred.
struct NotificationsSettingsView: View {
    @State private var dailyReminder = true
    @State private var weeklyDigest = false

    var body: some View {
        List {
            Section(String(localized: "reminders")) {
                Toggle(String(localized: "daily_reminder"), isOn: $dailyReminder)
                Toggle(String(localized: "weekly_digest"), isOn: $weeklyDigest)
            }

            Section {
                Text(String(localized: "notifications_hint"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "notifications_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
