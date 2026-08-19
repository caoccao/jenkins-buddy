import Foundation

struct AppStrings: Sendable {
    let language: AppLanguage

    init(language: AppLanguage) {
        self.language = language
    }

    subscript(key: AppStringKey) -> String {
        let localized = Self.catalogs[language]?[key]
        return localized ?? EnglishStrings.values[key] ?? key.rawValue
    }

    func languageName(_ language: AppLanguage) -> String {
        language.title
    }

    func formatted(_ key: AppStringKey, _ arguments: CVarArg...) -> String {
        String(format: self[key], locale: language.locale, arguments: arguments)
    }

    func status(_ status: BuildStatus) -> String {
        switch status {
        case .success: self[.statusSuccess]
        case .failure: self[.statusFailure]
        case .unstable: self[.statusUnstable]
        case .aborted: self[.statusAborted]
        case .notBuilt: self[.statusNotBuilt]
        case .disabled: self[.statusDisabled]
        case .building: self[.statusBuilding]
        case .unknown: self[.unknownStatus]
        }
    }

    func event(_ kind: BuildEvent.Kind) -> String {
        switch kind {
        case .started: self[.eventStarted]
        case .succeeded: self[.eventSucceeded]
        case .failed: self[.eventFailed]
        case .unstable: self[.statusUnstable]
        }
    }

    static let catalogs: [AppLanguage: [AppStringKey: String]] = [
        .english: EnglishStrings.values,
        .spanish: SpanishStrings.values,
        .french: FrenchStrings.values,
        .german: GermanStrings.values,
        .portuguese: PortugueseStrings.values,
        .simplifiedChinese: SimplifiedChineseStrings.values,
        .traditionalChineseHK: TraditionalChineseHKStrings.values,
        .traditionalChineseTW: TraditionalChineseTWStrings.values,
        .japanese: JapaneseStrings.values,
        .korean: KoreanStrings.values
    ]
}
