import Foundation

/// All premium-gated features in the app.
/// Add new cases here as the product grows — no other file needs changing.
enum PremiumFeature: String, CaseIterable, Identifiable {

    /// AI spending coach and insight detail screen.
    case aiCoach = "ai_coach"

    /// Financial literacy lessons and articles (placeholder).
    case financialLessons = "financial_lessons"

    /// Advanced statement import: multi-bank, OCR, Halyk PDF (placeholder).
    case advancedImport = "advanced_import"

    // MARK: - Identifiable

    var id: String { rawValue }

    // MARK: - UI Metadata

    var iconName: String {
        switch self {
        case .aiCoach:           "sparkles"
        case .financialLessons:  "book.fill"
        case .advancedImport:    "doc.badge.plus"
        }
    }

    var localizedName: String {
        String(localized: String.LocalizationValue("feature_\(rawValue)_name"))
    }

    var localizedDescription: String {
        String(localized: String.LocalizationValue("feature_\(rawValue)_description"))
    }

    /// Short bullet points shown on the paywall screen.
    var benefits: [String] {
        switch self {
        case .aiCoach:
            return [
                String(localized: "benefit_ai_1"),
                String(localized: "benefit_ai_2"),
                String(localized: "benefit_ai_3")
            ]
        case .financialLessons:
            return [
                String(localized: "benefit_lessons_1"),
                String(localized: "benefit_lessons_2")
            ]
        case .advancedImport:
            return [
                String(localized: "benefit_import_1"),
                String(localized: "benefit_import_2"),
                String(localized: "benefit_import_3")
            ]
        }
    }
}
