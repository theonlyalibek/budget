import SwiftUI

extension Color {
    /// Creates a Color from a hex string (e.g. "FF5733" or "#FF5733").
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: Double
        switch cleaned.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}

/// Preset color choices for custom categories.
enum CategoryColorPreset: String, CaseIterable, Identifiable {
    case red = "FF3B30"
    case orange = "FF9500"
    case yellow = "FFCC00"
    case green = "34C759"
    case teal = "5AC8FA"
    case blue = "007AFF"
    case indigo = "5856D6"
    case purple = "AF52DE"
    case pink = "FF2D55"
    case brown = "A2845E"
    case gray = "8E8E93"

    var id: String { rawValue }

    var color: Color { Color(hex: rawValue) }
}
