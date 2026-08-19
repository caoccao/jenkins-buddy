import Foundation

nonisolated struct BuildObservation: Codable, Equatable, Sendable {
    let number: Int?
    let status: BuildStatus

    init(snapshot: JobSnapshot) {
        number = snapshot.lastBuild?.number
        status = snapshot.status
    }

    init(number: Int?, status: BuildStatus) {
        self.number = number
        self.status = status
    }
}

nonisolated struct BuildEvent: Identifiable, Equatable, Sendable {
    enum Kind: String, CaseIterable, Sendable {
        case started
        case succeeded
        case failed
        case unstable
    }

    let id: UUID
    let kind: Kind
    let jobName: String
    let jobURL: URL
    let buildNumber: Int?

    init(kind: Kind, jobName: String, jobURL: URL, buildNumber: Int?, id: UUID = UUID()) {
        self.id = id
        self.kind = kind
        self.jobName = jobName
        self.jobURL = jobURL
        self.buildNumber = buildNumber
    }
}
