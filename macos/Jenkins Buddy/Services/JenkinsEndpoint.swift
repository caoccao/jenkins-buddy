import Foundation

nonisolated enum JenkinsEndpoint: Equatable, Sendable {
    case jobs
    case children(URL)
    case job(URL)

    func url(relativeTo baseURL: URL) -> URL {
        let resourceURL: URL
        switch self {
        case .jobs: resourceURL = baseURL
        case .children(let url): resourceURL = url
        case .job(let url): resourceURL = url
        }
        var components = URLComponents(
            url: resourceURL.appending(path: "api/json"),
            resolvingAgainstBaseURL: false
        ) ?? URLComponents()
        components.queryItems = [URLQueryItem(name: "tree", value: tree)]
        return components.url ?? resourceURL.appending(path: "api/json")
    }

    private var tree: String {
        switch self {
        case .jobs, .children:
            "jobs[name,fullName,url,color,_class,buildable]"
        case .job:
            "name,fullName,url,color,description,buildable,inQueue,builds[\(Self.buildFields)]{0,\(Self.buildHistoryLimit)},lastBuild[\(Self.buildFields)]"
        }
    }

    private static let buildHistoryLimit = 50
    private static let buildFields = "number,url,result,building,timestamp,duration,estimatedDuration,displayName"
}
