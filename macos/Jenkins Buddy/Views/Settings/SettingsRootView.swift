import SwiftUI

struct SettingsRootView: View {
    enum Section: String, CaseIterable, Identifiable {
        case jenkins
        case language
        case notifications

        var id: String { rawValue }
    }

    let settings: AppSettings
    let notifications: any NotificationDelivering
    @State var selection: Section
    @State private var jenkinsViewModel: JenkinsSettingsViewModel

    init(
        settings: AppSettings,
        credentials: any CredentialStore,
        jenkins: any JenkinsServing,
        notifications: any NotificationDelivering,
        selection: Section = .jenkins
    ) {
        self.settings = settings
        self.notifications = notifications
        _selection = State(initialValue: selection)
        _jenkinsViewModel = State(initialValue: JenkinsSettingsViewModel(
            settings: settings,
            credentials: credentials,
            jenkins: jenkins
        ))
    }

    var body: some View {
        let strings = AppStrings(language: settings.resolvedLanguage)
        NavigationSplitView {
            List(selection: $selection) {
                Label(strings[.jenkins], systemImage: "server.rack")
                    .tag(Section.jenkins)
                    .accessibilityIdentifier("settings-section-jenkins")
                Label(strings[.language], systemImage: "globe")
                    .tag(Section.language)
                    .accessibilityIdentifier("settings-section-language")
                Label(strings[.notifications], systemImage: "bell")
                    .tag(Section.notifications)
                    .accessibilityIdentifier("settings-section-notifications")
            }
            .navigationSplitViewColumnWidth(
                min: AppLayout.settingsSidebarMinimumWidth,
                ideal: AppLayout.settingsSidebarWidth,
                max: AppLayout.settingsSidebarMaximumWidth
            )
            .listStyle(.sidebar)
        } detail: {
            Group {
                switch selection {
                case .jenkins:
                    JenkinsSettingsView(viewModel: jenkinsViewModel, strings: strings)
                case .language:
                    LanguageSettingsView(settings: settings, strings: strings)
                case .notifications:
                    NotificationSettingsView(settings: settings, notifications: notifications, strings: strings)
                }
            }
            .frame(maxWidth: AppLayout.settingsContentWidth)
            .padding(AppLayout.contentPadding)
        }
        .frame(minWidth: AppLayout.settingsWidth, minHeight: AppLayout.settingsHeight)
        .environment(\.locale, settings.resolvedLanguage.locale)
    }
}
