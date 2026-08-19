import Foundation

nonisolated enum AppLanguage: String, CaseIterable, Codable, Identifiable, Sendable {
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case portuguese = "pt"
    case simplifiedChinese = "zh-Hans"
    case traditionalChineseHK = "zh-Hant-HK"
    case traditionalChineseTW = "zh-Hant-TW"
    case japanese = "ja"
    case korean = "ko"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        case .french: "Français"
        case .german: "Deutsch"
        case .portuguese: "Português"
        case .simplifiedChinese: "简体中文"
        case .traditionalChineseHK: "繁體中文（香港）"
        case .traditionalChineseTW: "繁體中文（台灣）"
        case .japanese: "日本語"
        case .korean: "한국어"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    static let sortedByTitle: [AppLanguage] = allCases.sorted { lhs, rhs in
        let comparison = lhs.title.localizedStandardCompare(rhs.title)
        if comparison == .orderedSame {
            return lhs.rawValue < rhs.rawValue
        }
        return comparison == .orderedAscending
    }

    static func preferred(from preferredLanguages: [String] = Locale.preferredLanguages) -> AppLanguage {
        guard let preferred = preferredLanguages.first?.lowercased() else { return .english }
        if preferred.hasPrefix("zh-hant-hk") || preferred.hasPrefix("zh-hk") {
            return .traditionalChineseHK
        }
        if preferred.hasPrefix("zh-hant") || preferred.hasPrefix("zh-tw") { return .traditionalChineseTW }
        if preferred.hasPrefix("zh") { return .simplifiedChinese }
        if preferred.hasPrefix("ja") { return .japanese }
        if preferred.hasPrefix("de") { return .german }
        if preferred.hasPrefix("fr") { return .french }
        if preferred.hasPrefix("es") { return .spanish }
        if preferred.hasPrefix("pt") { return .portuguese }
        if preferred.hasPrefix("ko") { return .korean }
        return .english
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if let language = AppLanguage(rawValue: value) {
            self = language
            return
        }

        switch value {
        case "system": self = Self.preferred()
        case "english": self = .english
        case "spanish": self = .spanish
        case "french": self = .french
        case "german": self = .german
        case "portugueseBrazil": self = .portuguese
        case "simplifiedChinese": self = .simplifiedChinese
        case "traditionalChinese": self = .traditionalChineseTW
        case "japanese": self = .japanese
        case "korean": self = .korean
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported app language: \(value)"
            )
        }
    }
}
