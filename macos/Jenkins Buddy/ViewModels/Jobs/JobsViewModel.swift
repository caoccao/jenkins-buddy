import Foundation
import Observation

@MainActor
@Observable
final class JobsViewModel {
    var searchText = ""

    var normalizedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isSearching: Bool { !normalizedSearchText.isEmpty }

    func filteredJobs(_ jobs: [JenkinsJob]) -> [JenkinsJob] {
        let query = normalizedSearchText
        guard !query.isEmpty else { return jobs }
        return jobs.compactMap { filter($0, query: query) }
    }

    private func filter(_ job: JenkinsJob, query: String) -> JenkinsJob? {
        let filteredChildren = job.children.compactMap { filter($0, query: query) }
        let matches = job.displayName.localizedCaseInsensitiveContains(query)
            || job.displayFullName.localizedCaseInsensitiveContains(query)
        guard matches || !filteredChildren.isEmpty else { return nil }
        return JenkinsJob(
            name: job.name,
            fullName: job.fullName,
            url: job.url,
            color: job.color,
            objectClass: job.objectClass,
            buildable: job.buildable,
            children: matches ? job.children : filteredChildren
        )
    }
}
