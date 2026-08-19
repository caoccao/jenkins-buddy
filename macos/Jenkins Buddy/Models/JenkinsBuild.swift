import Foundation

nonisolated struct JenkinsBuild: Codable, Equatable, Sendable {
    let number: Int
    let url: URL
    let result: String?
    let building: Bool
    let timestamp: TimeInterval
    let duration: TimeInterval
    let estimatedDuration: TimeInterval
    let displayName: String

    var status: BuildStatus { BuildStatus(result: result, building: building) }
    var startedAt: Date { Date(timeIntervalSince1970: timestamp / 1_000) }
}

nonisolated struct JenkinsJobDetailResponse: Decodable, Sendable {
    let name: String
    let fullName: String?
    let url: URL
    let color: String?
    let description: String?
    let buildable: Bool?
    let inQueue: Bool?
    let lastBuild: JenkinsBuild?
    let lastCompletedBuild: JenkinsBuild?
    let lastSuccessfulBuild: JenkinsBuild?
    let lastFailedBuild: JenkinsBuild?
    let builds: [JenkinsBuild]?

    func snapshot(fetchedAt: Date = Date()) -> JobSnapshot {
        JobSnapshot(
            name: fullName ?? name,
            url: url,
            color: color,
            description: description,
            buildable: buildable ?? true,
            inQueue: inQueue ?? false,
            lastBuild: lastBuild,
            lastCompletedBuild: lastCompletedBuild,
            lastSuccessfulBuild: lastSuccessfulBuild,
            lastFailedBuild: lastFailedBuild,
            builds: builds,
            fetchedAt: fetchedAt
        )
    }
}

nonisolated struct JobSnapshot: Codable, Equatable, Sendable {
    let name: String
    let url: URL
    let color: String?
    let description: String?
    let buildable: Bool
    let inQueue: Bool
    let lastBuild: JenkinsBuild?
    let lastCompletedBuild: JenkinsBuild?
    let lastSuccessfulBuild: JenkinsBuild?
    let lastFailedBuild: JenkinsBuild?
    let builds: [JenkinsBuild]?
    let fetchedAt: Date

    init(
        name: String,
        url: URL,
        color: String?,
        description: String?,
        buildable: Bool,
        inQueue: Bool,
        lastBuild: JenkinsBuild?,
        lastCompletedBuild: JenkinsBuild?,
        lastSuccessfulBuild: JenkinsBuild?,
        lastFailedBuild: JenkinsBuild?,
        builds: [JenkinsBuild]? = nil,
        fetchedAt: Date
    ) {
        self.name = name
        self.url = url
        self.color = color
        self.description = description
        self.buildable = buildable
        self.inQueue = inQueue
        self.lastBuild = lastBuild
        self.lastCompletedBuild = lastCompletedBuild
        self.lastSuccessfulBuild = lastSuccessfulBuild
        self.lastFailedBuild = lastFailedBuild
        self.builds = builds
        self.fetchedAt = fetchedAt
    }

    var displayName: String { JenkinsDisplayName.decoded(name) }

    var buildHistory: [JenkinsBuild] {
        let availableBuilds: [JenkinsBuild]
        if let builds, !builds.isEmpty {
            availableBuilds = builds
        } else {
            availableBuilds = [
                lastBuild,
                lastCompletedBuild,
                lastSuccessfulBuild,
                lastFailedBuild
            ].compactMap { $0 }
        }
        var seenNumbers = Set<Int>()
        return availableBuilds
            .sorted { $0.number > $1.number }
            .filter { seenNumbers.insert($0.number).inserted }
    }

    var status: BuildStatus {
        if !buildable { return .disabled }
        return lastBuild?.status ?? BuildStatus(jenkinsColor: color)
    }
}
