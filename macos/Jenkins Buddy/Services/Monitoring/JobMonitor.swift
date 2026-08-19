import Foundation

actor JobMonitor {
    private var observations: [URL: BuildObservation] = [:]
    private let detector: BuildEventDetector

    init(detector: BuildEventDetector = BuildEventDetector()) {
        self.detector = detector
    }

    func record(_ snapshot: JobSnapshot) -> [BuildEvent] {
        let current = BuildObservation(snapshot: snapshot)
        guard let previous = observations[snapshot.url] else {
            observations[snapshot.url] = current
            return []
        }
        observations[snapshot.url] = current
        return detector.events(
            previous: previous,
            current: current,
            jobName: snapshot.name,
            jobURL: snapshot.url
        )
    }

    func remove(urlsToKeep: Set<URL>) {
        observations = observations.filter { urlsToKeep.contains($0.key) }
    }

    func reset() {
        observations.removeAll()
    }

    func observation(for url: URL) -> BuildObservation? {
        observations[url]
    }
}
