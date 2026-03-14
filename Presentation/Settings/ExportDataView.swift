import SwiftUI

/// Export data screen — Figma `ExportScreen`.
/// Shell placeholder; CSV export will be implemented in Step 3.
struct ExportDataView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    Text(String(localized: "export_description"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section(String(localized: "export_formats")) {
                Label {
                    HStack {
                        Text("CSV")
                        Spacer()
                        Text(String(localized: "coming_soon"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "tablecells")
                }

                Label {
                    HStack {
                        Text("PDF")
                        Spacer()
                        Text(String(localized: "coming_soon"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "doc.richtext")
                }
            }
        }
        .navigationTitle(String(localized: "export_title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
