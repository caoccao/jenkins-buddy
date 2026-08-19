import Foundation

nonisolated struct HTTPResponse: Equatable, Sendable {
    let data: Data
    let statusCode: Int
    let url: URL?
}

protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> HTTPResponse
}

nonisolated enum RedirectPolicy {
    static func allows(from originalURL: URL?, to proposedURL: URL?) -> Bool {
        guard let originalURL, let proposedURL,
              let original = URLComponents(url: originalURL, resolvingAgainstBaseURL: false),
              let proposed = URLComponents(url: proposedURL, resolvingAgainstBaseURL: false),
              let scheme = original.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = original.host, !host.isEmpty else {
            return false
        }
        guard host.lowercased() == proposed.host?.lowercased() else { return false }
        let proposedScheme = proposed.scheme?.lowercased()
        if scheme == proposedScheme {
            return effectivePort(original) == effectivePort(proposed)
        }
        return scheme == "http"
            && proposedScheme == "https"
            && effectivePort(original) == 80
            && effectivePort(proposed) == 443
    }

    static func allowsAuthenticatedResource(configuredURL: URL, resourceURL: URL) -> Bool {
        guard let configured = URLComponents(url: configuredURL, resolvingAgainstBaseURL: false),
              let resource = URLComponents(url: resourceURL, resolvingAgainstBaseURL: false) else {
            return false
        }
        return configured.scheme?.lowercased() == resource.scheme?.lowercased()
            && configured.host?.lowercased() == resource.host?.lowercased()
            && effectivePort(configured) == effectivePort(resource)
    }

    private static func effectivePort(_ components: URLComponents) -> Int? {
        if let port = components.port { return port }
        return switch components.scheme?.lowercased() {
        case "http": 80
        case "https": 443
        default: nil
        }
    }
}

nonisolated enum JenkinsResourceIdentity {
    static func matches(_ expectedURL: URL, _ actualURL: URL) -> Bool {
        guard RedirectPolicy.allowsAuthenticatedResource(
            configuredURL: expectedURL,
            resourceURL: actualURL
        ) else {
            return false
        }
        return normalizedPath(expectedURL) == normalizedPath(actualURL)
    }

    private static func normalizedPath(_ url: URL) -> String {
        let path = url.path(percentEncoded: false)
        guard path.count > 1 else { return path }
        return path.hasSuffix("/") ? String(path.dropLast()) : path
    }
}

final class SameOriginRedirectDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        let allowed = RedirectPolicy.allows(
            from: task.originalRequest?.url ?? response.url,
            to: request.url
        )
        completionHandler(allowed ? request : nil)
    }
}

actor URLSessionTransport: HTTPTransport {
    private let session: URLSession

    init(configuration: URLSessionConfiguration = .ephemeral) {
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(
            configuration: configuration,
            delegate: SameOriginRedirectDelegate(),
            delegateQueue: nil
        )
    }

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw JenkinsClientError.invalidResponse
        }
        return HTTPResponse(data: data, statusCode: response.statusCode, url: response.url)
    }
}
