import Foundation

nonisolated struct CredentialKey: Hashable, Sendable {
    let controllerURL: URL
    let username: String

    init(connection: JenkinsConnection) {
        controllerURL = connection.baseURL
        username = connection.username
    }

    var account: String {
        "\(controllerURL.absoluteString)|\(username)"
    }
}
