import Foundation

nonisolated enum JenkinsConnectionError: Error, Equatable, LocalizedError {
    case emptyURL
    case invalidURL
    case unsupportedScheme
    case insecureHTTP
    case missingHost

    var errorDescription: String? {
        switch self {
        case .emptyURL: "The Jenkins URL is required."
        case .invalidURL: "The Jenkins URL is invalid."
        case .unsupportedScheme: "Use an HTTPS Jenkins URL."
        case .insecureHTTP: "Plain HTTP is allowed only for a local Jenkins instance."
        case .missingHost: "The Jenkins URL must include a host."
        }
    }
}

nonisolated struct JenkinsConnection: Equatable, Sendable {
    let baseURL: URL
    let username: String
    let token: String

    init(serverURL: String, username: String, token: String) throws {
        let trimmedURL = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else { throw JenkinsConnectionError.emptyURL }
        guard var components = URLComponents(string: trimmedURL) else {
            throw JenkinsConnectionError.invalidURL
        }
        guard components.user == nil,
              components.password == nil,
              components.query == nil,
              components.fragment == nil else {
            throw JenkinsConnectionError.invalidURL
        }
        let pathSegments = components.path.split(separator: "/")
        components.path = pathSegments.isEmpty ? "/" : "/" + pathSegments.joined(separator: "/") + "/"
        guard let scheme = components.scheme?.lowercased(), ["http", "https"].contains(scheme) else {
            throw JenkinsConnectionError.unsupportedScheme
        }
        guard let host = components.host, !host.isEmpty, let url = components.url else {
            throw JenkinsConnectionError.missingHost
        }
        if scheme == "http" && !Self.localHosts.contains(host.lowercased()) {
            throw JenkinsConnectionError.insecureHTTP
        }
        baseURL = url
        self.username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        self.token = token
    }

    var authorizationHeader: String {
        let credentials = Data("\(username):\(token)".utf8).base64EncodedString()
        return "Basic \(credentials)"
    }

    var credentialKey: CredentialKey {
        CredentialKey(connection: self)
    }

    private static let localHosts: Set<String> = ["localhost", "127.0.0.1", "::1"]
}
