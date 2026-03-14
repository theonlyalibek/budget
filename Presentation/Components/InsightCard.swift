import SwiftUI

/// AI insight card for the Dashboard — Figma `InsightCard` component.
/// Shows a brief AI-generated tip with a "Подробнее" action.
struct InsightCard: View {
    let title: String
    let message: String
    var onTapDetail: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Spacer()
            }

            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(3)

            if let onTapDetail {
                Button(action: onTapDetail) {
                    Text(String(localized: "insight_more"))
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
