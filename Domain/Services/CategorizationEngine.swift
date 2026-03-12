import Foundation

final class CategorizationEngine: CategorizationEngineProtocol {

    // MARK: - Built-in keyword rules

    /// Each rule: (lowercased keywords, category, subcategory, isSubscription)
    private struct Rule: Sendable {
        let keywords: [String]
        let category: Category
        let subcategory: String
        let isSubscription: Bool

        init(
            _ keywords: [String],
            _ category: Category,
            subcategory: String = "",
            isSubscription: Bool = false
        ) {
            self.keywords = keywords
            self.category = category
            self.subcategory = subcategory
            self.isSubscription = isSubscription
        }
    }

    private let builtInRules: [Rule] = [
        // Food & Groceries
        Rule(["magnum", "small", "grossmart", "anvar", "рамстор", "fresh market"], .food, subcategory: "Продукты"),
        Rule(["glovo", "wolt", "wolt.com", "яндекс еда", "yandex eda"], .food, subcategory: "Доставка еды"),
        Rule(["starbucks", "coffeeboom", "кофе", "costa", "zyp zyp"], .food, subcategory: "Кафе"),
        Rule(["мкр", "базар", "рынок"], .food, subcategory: "Рынок"),
        Rule(["mcdonalds", "mcdonald", "burger king", "kfc", "hardees", "dodopay", "dodo pizza"], .food, subcategory: "Фастфуд"),

        // Transport
        Rule(["yandex go", "яндекс го", "uber", "indriver", "indrive"], .transport, subcategory: "Такси"),
        Rule(["onay", "оңай", "автобус"], .transport, subcategory: "Общественный"),
        Rule(["паркинг", "parking", "парковк"], .transport, subcategory: "Парковка"),
        Rule(["жанармай", "бензин", "gas station", "qazaq gas", "helios", "sinooil"], .transport, subcategory: "Бензин"),

        // Housing
        Rule(["аренда", "квартира", "rent"], .housing),

        // Utilities
        Rule(["кск", "алматыэнерго", "электричество", "водоканал", "газ", "интернет", "beeline", "activ", "tele2", "kcell", "altel"], .utilities),

        // Entertainment
        Rule(["кинопарк", "chaplin", "cinema", "imax"], .entertainment),
        Rule(["spotify", "netflix", "youtube premium", "kinopoisk", "apple music"], .entertainment, subcategory: "Стриминг", isSubscription: true),

        // Health
        Rule(["аптека", "pharmacy", "pharma", "клиника", "dentist", "стоматолог"], .health),

        // Clothing
        Rule(["zara", "h&m", "uniqlo", "nike", "adidas", "lcwaikiki", "bershka"], .clothing),

        // Education
        Rule(["курс", "udemy", "coursera", "книга", "book"], .education),

        // Subscriptions (standalone)
        Rule(["icloud", "apple one", "google one", "facebk", "meta", "chatgpt"], .subscriptions, isSubscription: true),

        // Transfers
        Rule(["перевод", "p2p", "transfer"], .transfers)
    ]

    // MARK: - CategorizationEngineProtocol

    func categorize(_ description: String) -> CategorizationResult {
        categorize(description, userRules: [])
    }

    func categorize(_ description: String, userRules: [CategoryRule]) -> CategorizationResult {
        let lowered = description.lowercased()

        // 1. Check user-defined rules first (they take priority)
        for rule in userRules {
            if lowered.contains(rule.keyword.lowercased()) {
                let category = Category(rawValue: rule.categoryName) ?? .other
                return CategorizationResult(
                    category: category,
                    subcategory: "",
                    isSubscription: false
                )
            }
        }

        // 2. Check built-in keyword rules
        for rule in builtInRules {
            for keyword in rule.keywords {
                if lowered.contains(keyword) {
                    return CategorizationResult(
                        category: rule.category,
                        subcategory: rule.subcategory,
                        isSubscription: rule.isSubscription
                    )
                }
            }
        }

        // 3. No match
        return .unknown
    }
}
