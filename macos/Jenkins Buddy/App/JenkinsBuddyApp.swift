import AppKit
import SwiftUI

@main
struct JenkinsBuddyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let environment = AppEnvironment.shared

    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: environment.appViewModel)
                .frame(
                    idealWidth: AppLayout.defaultWindowWidth,
                    idealHeight: AppLayout.defaultWindowHeight
                )
        }
        .defaultSize(
            width: AppLayout.defaultWindowWidth,
            height: AppLayout.defaultWindowHeight
        )
        .windowResizability(.contentMinSize)
        .commands {
            AppCommands(settings: environment.settings)
        }

        Window(
            AppStrings(language: environment.settings.resolvedLanguage)[.settings],
            id: SettingsWindowRoute.sceneID
        ) {
            SettingsRootView(
                settings: environment.settings,
                credentials: environment.credentials,
                jenkins: environment.jenkins,
                notifications: environment.notifications
            )
        }
        .defaultSize(width: AppLayout.settingsWidth, height: AppLayout.settingsHeight)
        .windowResizability(.contentMinSize)
    }
}
