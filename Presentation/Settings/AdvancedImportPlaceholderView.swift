import SwiftUI

/// Advanced statement import — premium feature placeholder (Step 4).
/// Future: Halyk PDF parser, OCR bank screenshot recognition, multi-account merge.
struct AdvancedImportPlaceholderView: View {
    var body: some View {
        List {
            Section {
                EmptyStateBlock(
                    systemImage: "doc.badge.plus",
                    title: String(localized: "feature_advanced_import_name"),
                    description: String(localized: "advanced_import_coming_description")
                )
                .frame(minHeight: 240)
            }

            Section(String(localized: "advanced_import_planned")) {
                featureRow(icon: "building.columns.fill",
                           color: .orange,
                           text: String(localized: "advanced_import_halyk"))
                featureRow(icon: "camera.viewfinder",
                           color: .blue,
                           text: String(localized: "advanced_import_ocr"))
                featureRow(icon: "arrow.triangle.merge",
                           color: .purple,
                           text: String(localized: "advanced_import_merge"))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(String(localized: "feature_advanced_import_name"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
            Spacer()
            Text(String(localized: "coming_soon"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
