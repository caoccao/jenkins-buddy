import AppKit
import SwiftUI

struct NotificationSettingsView: View {
    let settings: AppSettings
    let notifications: any NotificationDelivering
    let strings: AppStrings
    @State private var permissionGranted: Bool?

    init(
        settings: AppSettings,
        notifications: any NotificationDelivering,
        strings: AppStrings,
        permissionGranted: Bool? = nil
    ) {
        self.settings = settings
        self.notifications = notifications
        self.strings = strings
        _permissionGranted = State(initialValue: permissionGranted)
    }

    var body: some View {
        Form {
            Section {
                Toggle(strings[.notificationsEnabled], isOn: enabledBinding)
                    .accessibilityIdentifier("notifications-enabled")
            }

            Section(strings[.notifications]) {
                Toggle(strings[.notifyBuildStarted], isOn: binding(\.buildStarted))
                Toggle(strings[.notifyBuildSucceeded], isOn: binding(\.buildSucceeded))
                Toggle(strings[.notifyBuildFailed], isOn: binding(\.buildFailed))
                Toggle(strings[.playSound], isOn: binding(\.playSound))
            }
            .disabled(!settings.state.notifications.isEnabled)

            Section(strings[.notificationPermission]) {
                HStack {
                    Button(strings[.requestPermission]) {
                        Task {
                            permissionGranted = try? await notifications.requestAuthorization()
                        }
                    }
                    if let permissionGranted {
                        Image(systemName: permissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(permissionGranted ? .green : .red)
                    }
                    if permissionGranted == false {
                        Button(strings[.openSystemSettings]) { openSystemSettings() }
                    }
                }
                Button(strings[.sendTestNotification]) {
                    Task { await sendTestNotification() }
                }
            }

            Text(strings[.monitoringNote])
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .navigationTitle(strings[.notifications])
    }

    func binding(_ keyPath: WritableKeyPath<NotificationSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { settings.state.notifications[keyPath: keyPath] },
            set: { value in
                settings.update { $0.notifications[keyPath: keyPath] = value }
            }
        )
    }

    var enabledBinding: Binding<Bool> {
        Binding(
            get: { settings.state.notifications.isEnabled },
            set: { enabled in
                settings.update { $0.notifications.isEnabled = enabled }
                if enabled {
                    Task {
                        permissionGranted = try? await notifications.requestAuthorization()
                    }
                }
            }
        )
    }

    func sendTestNotification() async {
        guard (try? await notifications.requestAuthorization()) == true else {
            permissionGranted = false
            return
        }
        permissionGranted = true
        let configuredURL = try? JenkinsConnection(
            serverURL: settings.state.jenkins.serverURL,
            username: settings.state.jenkins.username,
            token: ""
        ).baseURL
        guard let jobURL = configuredURL ?? URL(string: "https://localhost/") else { return }
        let event = BuildEvent(
            kind: .succeeded,
            jobName: strings[.appName],
            jobURL: jobURL,
            buildNumber: nil
        )
        try? await notifications.deliver(
            event,
            title: strings[.appName],
            body: strings[.notificationTestBody],
            playSound: settings.state.notifications.playSound
        )
    }

    private func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension") else { return }
        NSWorkspace.shared.open(url)
    }
}
