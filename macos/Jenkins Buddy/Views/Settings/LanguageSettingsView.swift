import SwiftUI

struct LanguageSettingsView: View {
    let settings: AppSettings
    let strings: AppStrings

    var body: some View {
        Form {
            Section(strings[.language]) {
                ForEach(AppLanguage.sortedByTitle) { language in
                    Button {
                        settings.update { $0.language = language }
                    } label: {
                        HStack {
                            Text(language.title)
                            Spacer()
                            if settings.state.language == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                                    .accessibilityIdentifier("settings-language-\(language.rawValue)-checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("settings-language-\(language.rawValue)")
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(strings[.language])
    }
}
