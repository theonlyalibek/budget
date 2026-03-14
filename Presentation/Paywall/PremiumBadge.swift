import SwiftUI

/// Small "PRO" pill shown on locked feature rows and navigation items.
struct PremiumBadge: View {
    var body: some View {
        Text(String(localized: "badge_pro"))
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
    }
}
