import Foundation

nonisolated struct BuildEventDetector: Sendable {
    func events(
        previous: BuildObservation,
        current: BuildObservation,
        jobName: String,
        jobURL: URL
    ) -> [BuildEvent] {
        if current.status == .building,
           previous.status != .building,
           current.number != previous.number {
            return [BuildEvent(kind: .started, jobName: jobName, jobURL: jobURL, buildNumber: current.number)]
        }

        guard current.status != .building else { return [] }
        let changedBuild = current.number != previous.number
        let changedStatus = current.status != previous.status
        guard changedBuild || changedStatus else { return [] }

        if current.status == .success {
            return [BuildEvent(kind: .succeeded, jobName: jobName, jobURL: jobURL, buildNumber: current.number)]
        }
        if current.status == .failure {
            return [BuildEvent(kind: .failed, jobName: jobName, jobURL: jobURL, buildNumber: current.number)]
        }
        if current.status == .unstable {
            return [BuildEvent(kind: .unstable, jobName: jobName, jobURL: jobURL, buildNumber: current.number)]
        }
        return []
    }
}
