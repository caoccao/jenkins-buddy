import Foundation

nonisolated struct JenkinsJob: Identifiable, Codable, Equatable, Sendable {
    var id: String { "\(fullName)|\(url.absoluteString)" }
    let name: String
    let fullName: String
    let url: URL
    let color: String?
    let objectClass: String?
    let buildable: Bool?
    let children: [JenkinsJob]

    init(
        name: String,
        fullName: String,
        url: URL,
        color: String?,
        objectClass: String? = nil,
        buildable: Bool? = nil,
        children: [JenkinsJob]
    ) {
        self.name = name
        self.fullName = fullName
        self.url = url
        self.color = color
        self.objectClass = objectClass
        self.buildable = buildable
        self.children = children
    }

    var status: BuildStatus { BuildStatus(jenkinsColor: color) }
    var displayName: String { JenkinsDisplayName.decoded(name) }
    var displayFullName: String { JenkinsDisplayName.decoded(fullName) }
    var isContainer: Bool {
        let className = objectClass?.lowercased() ?? ""
        if !children.isEmpty
            || className.contains("folder")
            || className.contains("multibranch") {
            return true
        }
        if buildable == true {
            return false
        }
        return color == nil
    }
}

nonisolated enum JenkinsDisplayName {
    static func decoded(_ value: String) -> String {
        var displayValue = value
        for _ in 0..<2 {
            guard let decoded = displayValue.removingPercentEncoding,
                  decoded != displayValue else {
                break
            }
            displayValue = decoded
        }
        return displayValue
    }
}

nonisolated struct JenkinsJobResponse: Decodable, Sendable {
    let jobs: [JenkinsJobPayload]
}

nonisolated struct JenkinsJobPayload: Decodable, Sendable {
    let name: String
    let fullName: String?
    let url: URL
    let color: String?
    let objectClass: String?
    let buildable: Bool?
    let jobs: [JenkinsJobPayload]?

    enum CodingKeys: String, CodingKey {
        case name, fullName, url, color, buildable, jobs
        case objectClass = "_class"
    }

    func model(parentName: String? = nil) -> JenkinsJob {
        let resolvedName = fullName ?? parentName.map { "\($0)/\(name)" } ?? name
        return JenkinsJob(
            name: name,
            fullName: resolvedName,
            url: url,
            color: color,
            objectClass: objectClass,
            buildable: buildable,
            children: (jobs ?? []).map { $0.model(parentName: resolvedName) }
        )
    }
}
