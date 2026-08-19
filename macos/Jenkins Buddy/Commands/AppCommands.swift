import SwiftUI

struct AppCommands: Commands {
    @Bindable var settings: AppSettings
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        let strings = AppStrings(language: settings.resolvedLanguage)
        CommandGroup(replacing: .appSettings) {
            Button(strings[.settings]) {
                SettingsWindowRoute.open(using: openWindow)
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        CommandGroup(after: .toolbar) {
            Button(strings[.refresh]) {
                AppEventBus.refresh()
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }
}
