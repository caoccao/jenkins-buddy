import Foundation
import Observation

@MainActor
@Observable
final class JenkinsSettingsViewModel {
    enum TestState: Equatable {
        case idle
        case testing
        case success
        case failure(String)
    }

    var serverURL: String
    var username: String
    var token: String
    var refreshInterval: Double
    var testState = TestState.idle
    var didSave = false

    private let settings: AppSettings
    private let credentials: any CredentialStore
    private let jenkins: any JenkinsServing

    init(
        settings: AppSettings,
        credentials: any CredentialStore,
        jenkins: any JenkinsServing
    ) {
        self.settings = settings
        self.credentials = credentials
        self.jenkins = jenkins
        serverURL = settings.state.jenkins.serverURL
        username = settings.state.jenkins.username
        if let connection = try? JenkinsConnection(
            serverURL: settings.state.jenkins.serverURL,
            username: settings.state.jenkins.username,
            token: ""
        ) {
            token = (try? credentials.token(for: connection.credentialKey)) ?? ""
        } else {
            token = ""
        }
        refreshInterval = settings.state.jenkins.refreshInterval
    }

    var canSubmit: Bool {
        !serverURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !token.isEmpty
    }

    var connectionIdentityChanged: Bool {
        guard let current = try? JenkinsConnection(
            serverURL: serverURL,
            username: username,
            token: token
        ), let stored = try? JenkinsConnection(
            serverURL: settings.state.jenkins.serverURL,
            username: settings.state.jenkins.username,
            token: ""
        ) else {
            return false
        }
        return current.credentialKey != stored.credentialKey
    }

    func testConnection() async {
        testState = .testing
        do {
            let connection = try JenkinsConnection(serverURL: serverURL, username: username, token: token)
            _ = try await jenkins.fetchJobs(connection: connection)
            testState = .success
        } catch {
            testState = .failure(error.localizedDescription)
        }
    }

    @discardableResult
    func save() -> Bool {
        do {
            let connection = try JenkinsConnection(serverURL: serverURL, username: username, token: token)
            let newKey = connection.credentialKey
            let previousKey = try? JenkinsConnection(
                serverURL: settings.state.jenkins.serverURL,
                username: settings.state.jenkins.username,
                token: ""
            ).credentialKey
            try credentials.save(token: token, for: newKey)
            if let previousKey, previousKey != newKey {
                try? credentials.deleteToken(for: previousKey)
            }
            settings.update { state in
                state.jenkins.serverURL = connection.baseURL.absoluteString
                state.jenkins.username = connection.username
                state.jenkins.refreshInterval = max(5, refreshInterval)
            }
            didSave = true
            if previousKey != nil, previousKey != newKey {
                AppEventBus.connectionChanged()
            } else {
                AppEventBus.refresh()
            }
            return true
        } catch {
            testState = .failure(error.localizedDescription)
            didSave = false
            return false
        }
    }
}
