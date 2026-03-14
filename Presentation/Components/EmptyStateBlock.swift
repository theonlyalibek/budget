import SwiftUI

/// Reusable empty-state view matching Figma `EmptyStateBlock` component.
struct EmptyStateBlock: View {
    let systemImage: String
    let title: String
    var description: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: systemImage)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3.bold())

                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 32)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
    }
}
