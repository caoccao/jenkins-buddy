import Foundation

enum JenkinsClientError: Error, Equatable, LocalizedError {
    case invalidResponse
    case authenticationRequired
    case forbidden
    case notFound
    case crossOrigin
    case server(Int)
    case http(Int)
    case invalidPayload
    case networkUnavailable
    case tlsTrust
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "Jenkins returned an invalid response."
        case .authenticationRequired: "Jenkins rejected the credentials."
        case .forbidden: "The Jenkins account does not have permission."
        case .notFound: "The Jenkins resource was not found."
        case .crossOrigin: "Jenkins returned a job URL on a different origin."
        case .server(let status): "Jenkins is unavailable (HTTP \(status))."
        case .http(let status): "Jenkins returned HTTP \(status)."
        case .invalidPayload: "Jenkins returned data in an unexpected format."
        case .networkUnavailable: "Jenkins is unreachable. Check the network or VPN connection."
        case .tlsTrust: "The Jenkins TLS certificate is not trusted by the system."
        case .timeout: "The Jenkins request timed out."
        }
    }
}

protocol JenkinsServing: Sendable {
    func fetchJobs(connection: JenkinsConnection) async throws -> [JenkinsJob]
    func fetchChildren(containerURL: URL, connection: JenkinsConnection) async throws -> [JenkinsJob]
    func fetchJob(url: URL, connection: JenkinsConnection) async throws -> JobSnapshot
}

actor JenkinsClient: JenkinsServing {
    private let transport: any HTTPTransport
    private let decoder: JSONDecoder

    init(transport: any HTTPTransport = URLSessionTransport()) {
        self.transport = transport
        decoder = JSONDecoder()
    }

    func fetchJobs(connection: JenkinsConnection) async throws -> [JenkinsJob] {
        let data = try await request(.jobs, connection: connection)
        guard let response = try? decoder.decode(JenkinsJobResponse.self, from: data) else {
            throw JenkinsClientError.invalidPayload
        }
        return response.jobs.map { $0.model() }
    }

    func fetchChildren(containerURL: URL, connection: JenkinsConnection) async throws -> [JenkinsJob] {
        guard RedirectPolicy.allowsAuthenticatedResource(
            configuredURL: connection.baseURL,
            resourceURL: containerURL
        ) else {
            throw JenkinsClientError.crossOrigin
        }
        let data = try await request(.children(containerURL), connection: connection)
        guard let response = try? decoder.decode(JenkinsJobResponse.self, from: data) else {
            throw JenkinsClientError.invalidPayload
        }
        return response.jobs.map { $0.model() }
    }

    func fetchJob(url: URL, connection: JenkinsConnection) async throws -> JobSnapshot {
        let data = try await request(.job(url), connection: connection)
        guard let response = try? decoder.decode(JenkinsJobDetailResponse.self, from: data) else {
            throw JenkinsClientError.invalidPayload
        }
        let snapshot = response.snapshot()
        guard JenkinsResourceIdentity.matches(url, snapshot.url) else {
            throw JenkinsClientError.invalidPayload
        }
        return snapshot
    }

    private func request(_ endpoint: JenkinsEndpoint, connection: JenkinsConnection) async throws -> Data {
        let requestURL = endpoint.url(relativeTo: connection.baseURL)
        if case .job(let jobURL) = endpoint,
           !RedirectPolicy.allowsAuthenticatedResource(
               configuredURL: connection.baseURL,
               resourceURL: jobURL
           ) {
            throw JenkinsClientError.crossOrigin
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue(connection.authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Jenkins-Buddy/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
        let response: HTTPResponse
        do {
            response = try await transport.send(request)
        } catch let error as JenkinsClientError {
            throw error
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw JenkinsClientError.timeout
            case .serverCertificateUntrusted, .serverCertificateHasBadDate,
                 .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid,
                 .secureConnectionFailed:
                throw JenkinsClientError.tlsTrust
            default:
                throw JenkinsClientError.networkUnavailable
            }
        } catch {
            throw JenkinsClientError.invalidResponse
        }
        switch response.statusCode {
        case 200..<300: return response.data
        case 401: throw JenkinsClientError.authenticationRequired
        case 403: throw JenkinsClientError.forbidden
        case 404: throw JenkinsClientError.notFound
        case 500...599: throw JenkinsClientError.server(response.statusCode)
        default: throw JenkinsClientError.http(response.statusCode)
        }
    }
}

actor StubJenkinsService: JenkinsServing {
    var jobsResult: Result<[JenkinsJob], Error>
    var children: [URL: Result<[JenkinsJob], Error>]
    var snapshots: [URL: Result<JobSnapshot, Error>]

    init(
        jobsResult: Result<[JenkinsJob], Error> = .success([]),
        children: [URL: Result<[JenkinsJob], Error>] = [:],
        snapshots: [URL: Result<JobSnapshot, Error>] = [:]
    ) {
        self.jobsResult = jobsResult
        self.children = children
        self.snapshots = snapshots
    }

    func fetchJobs(connection: JenkinsConnection) throws -> [JenkinsJob] {
        try jobsResult.get()
    }

    func fetchChildren(containerURL: URL, connection: JenkinsConnection) throws -> [JenkinsJob] {
        try children[containerURL, default: .success([])].get()
    }

    func fetchJob(url: URL, connection: JenkinsConnection) throws -> JobSnapshot {
        try snapshots[url, default: .failure(JenkinsClientError.notFound)].get()
    }
}
