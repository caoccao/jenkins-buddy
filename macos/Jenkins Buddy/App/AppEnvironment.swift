import Foundation

@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let settings: AppSettings
    let credentials: any CredentialStore
    let jenkins: any JenkinsServing
    let notifications: any NotificationDelivering
    let stateStore: any AppStateStore
    let appViewModel: AppViewModel

    private init() {
        settings = AppSettings()
        credentials = KeychainCredentialStore()
        jenkins = JenkinsClient()
        notifications = UserNotificationService()
        if let store = try? SQLiteAppStateStore.defaultStore() {
            stateStore = store
        } else {
            stateStore = MemoryAppStateStore()
        }
        appViewModel = AppViewModel(
            settings: settings,
            credentials: credentials,
            jenkins: jenkins,
            notifications: notifications,
            stateStore: stateStore
        )
    }

}
