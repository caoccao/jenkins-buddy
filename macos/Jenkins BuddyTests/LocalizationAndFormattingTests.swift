import Foundation
import Testing
@testable import Jenkins_Buddy

@Suite("Localization and formatting")
struct LocalizationAndFormattingTests {
    @Test("Every advertised language has exact key parity and translated content")
    func catalogs() {
        let expectedKeys = Set(AppStringKey.allCases)
        #expect(Set(EnglishStrings.values.keys) == expectedKeys)
        #expect(Set(AppStrings.catalogs.keys) == Set(AppLanguage.allCases))

        for language in AppLanguage.allCases {
            let catalog = AppStrings.catalogs[language] ?? [:]
            #expect(Set(catalog.keys) == expectedKeys, "Catalog mismatch for \(language.rawValue)")
            #expect(catalog.values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
            #expect(catalog.values.allSatisfy { !$0.contains("TODO(i18n)") })
            let strings = AppStrings(language: language)
            for key in AppStringKey.allCases {
                #expect(!strings[key].isEmpty)
            }
            #expect(strings[.monitoredJobs].contains("%d"))
            #expect(strings[.notificationBuildWithNumber].contains("%d"))
            #expect(strings[.notificationBuildWithNumber].contains("%@"))
            #expect(strings[.notificationBuildWithoutNumber].contains("%@"))
            #expect(strings.formatted(.notificationBuildWithNumber, 17, strings.event(.failed)).contains("17"))
            #expect(strings.formatted(.notificationBuildWithoutNumber, strings.event(.failed)).contains(strings.event(.failed)))

            if language != .english {
                let sharedKeys = expectedKeys.intersection(catalog.keys)
                let identicalCount = sharedKeys.filter { catalog[$0] == EnglishStrings.values[$0] }.count
                let identicalRatio = Double(identicalCount) / Double(sharedKeys.count)
                #expect(identicalRatio < 0.4, "Catalog looks untranslated for \(language.rawValue)")
            }
        }
        #expect(AppStrings(language: .simplifiedChinese)[.settings] == "设置")
        #expect(AppStrings(language: .traditionalChineseHK)[.jobs] == "工作")
        #expect(AppStrings(language: .traditionalChineseTW)[.jobs] == "作業")
        #expect(AppStrings(language: .japanese).languageName(.japanese) == "日本語")
        #expect(AppStrings(language: .german).formatted(.monitoredJobs, 3).contains("3"))
    }

    @Test("Status and event labels cover every case")
    func labels() {
        let strings = AppStrings(language: .english)
        for status in BuildStatus.allCases {
            #expect(!strings.status(status).isEmpty)
        }
        for event in BuildEvent.Kind.allCases {
            #expect(!strings.event(event).isEmpty)
        }
    }

    @Test("Build values format for short and long durations")
    func formatting() {
        let english = Locale(identifier: "en_US")
        let german = Locale(identifier: "de_DE")
        #expect(BuildFormatting.duration(milliseconds: -10, locale: english).contains("0"))
        #expect(BuildFormatting.duration(milliseconds: 45_000, locale: english).contains("45"))
        #expect(BuildFormatting.duration(milliseconds: 65_000, locale: english).contains("1"))
        #expect(BuildFormatting.duration(milliseconds: 3_661_000, locale: english).contains("1"))
        #expect(!BuildFormatting.duration(milliseconds: 65_000, locale: german).isEmpty)
        #expect(!BuildFormatting.date(Date(timeIntervalSince1970: 0), locale: Locale(identifier: "en_US")).isEmpty)
    }
}
