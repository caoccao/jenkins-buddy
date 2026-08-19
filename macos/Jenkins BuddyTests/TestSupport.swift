import Foundation
@testable import Jenkins_Buddy

nonisolated enum Samples {
    static let baseURL = url("https://jenkins.example.com/jenkins")
    static let jobURL = url("https://jenkins.example.com/jenkins/job/mobile/")
    static let secondJobURL = url("https://jenkins.example.com/jenkins/job/backend/")

    static func url(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid test URL: \(value)")
        }
        return url
    }

    static func connection() throws -> JenkinsConnection {
        try JenkinsConnection(
            serverURL: baseURL.absoluteString,
            username: "developer",
            token: "secret"
        )
    }

    static func credentialKey() throws -> CredentialKey {
        try connection().credentialKey
    }

    static func build(
        number: Int = 42,
        result: String? = "SUCCESS",
        building: Bool = false,
        url: URL = jobURL.appending(path: "42")
    ) -> JenkinsBuild {
        JenkinsBuild(
            number: number,
            url: url,
            result: result,
            building: building,
            timestamp: 1_700_000_000_000,
            duration: 65_000,
            estimatedDuration: 70_000,
            displayName: "#\(number)"
        )
    }

    static func snapshot(
        name: String = "mobile",
        url: URL = jobURL,
        number: Int = 42,
        result: String? = "SUCCESS",
        building: Bool = false,
        fetchedAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> JobSnapshot {
        let build = build(number: number, result: result, building: building, url: url.appending(path: "\(number)"))
        return JobSnapshot(
            name: name,
            url: url,
            color: building ? "blue_anime" : result == "SUCCESS" ? "blue" : "red",
            description: "A sample Jenkins job",
            buildable: true,
            inQueue: false,
            lastBuild: build,
            lastCompletedBuild: building ? nil : build,
            lastSuccessfulBuild: result == "SUCCESS" ? build : nil,
            lastFailedBuild: result == "FAILURE" ? build : nil,
            builds: [build],
            fetchedAt: fetchedAt
        )
    }

    static func job(name: String = "mobile", url: URL = jobURL, children: [JenkinsJob] = []) -> JenkinsJob {
        JenkinsJob(name: name, fullName: name, url: url, color: children.isEmpty ? "blue" : nil, children: children)
    }
}

actor MockHTTPTransport: HTTPTransport {
    private var responses: [Result<HTTPResponse, Error>]
    private(set) var requests: [URLRequest] = []

    init(_ responses: [Result<HTTPResponse, Error>]) {
        self.responses = responses
    }

    func send(_ request: URLRequest) throws -> HTTPResponse {
        requests.append(request)
        guard !responses.isEmpty else { throw JenkinsClientError.invalidResponse }
        return try responses.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] { requests }
}

actor SequencedJenkinsService: JenkinsServing {
    private var jobsResults: [Result<[JenkinsJob], Error>]
    private var snapshotResults: [URL: [Result<JobSnapshot, Error>]]

    init(
        jobs: [Result<[JenkinsJob], Error>] = [.success([])],
        snapshots: [URL: [Result<JobSnapshot, Error>]] = [:]
    ) {
        jobsResults = jobs
        snapshotResults = snapshots
    }

    func fetchJobs(connection: JenkinsConnection) throws -> [JenkinsJob] {
        guard !jobsResults.isEmpty else { return [] }
        return try jobsResults.removeFirst().get()
    }

    func fetchChildren(containerURL: URL, connection: JenkinsConnection) -> [JenkinsJob] {
        []
    }

    func fetchJob(url: URL, connection: JenkinsConnection) throws -> JobSnapshot {
        guard var results = snapshotResults[url], !results.isEmpty else {
            throw JenkinsClientError.notFound
        }
        let result = results.removeFirst()
        snapshotResults[url] = results
        return try result.get()
    }
}

nonisolated final class LockedFlag: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValue = false

    var value: Bool { lock.withLock { storedValue } }
    func set() { lock.withLock { storedValue = true } }
}
