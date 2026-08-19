import Foundation

nonisolated struct AppTab: Identifiable, Codable, Equatable, Sendable {
    enum Kind: String, Codable, Sendable {
        case jobs
        case job
    }

    static let jobsID = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0))

    let id: UUID
    let kind: Kind
    var title: String
    var jobURL: URL?

    static var jobs: AppTab {
        AppTab(id: jobsID, kind: .jobs, title: "Jobs", jobURL: nil)
    }

    static func job(title: String, url: URL, id: UUID = UUID()) -> AppTab {
        AppTab(id: id, kind: .job, title: title, jobURL: url)
    }
}

nonisolated struct AppSessionState: Codable, Equatable, Sendable {
    var tabs: [AppTab]
    var selectedTabID: UUID

    static var initial: AppSessionState {
        AppSessionState(tabs: [.jobs], selectedTabID: AppTab.jobsID)
    }

    func normalized() -> AppSessionState {
        var uniqueTabs = [AppTab.jobs]
        var seenURLs = Set<String>()
        for tab in tabs where tab.kind == .job {
            guard let url = tab.jobURL else { continue }
            let key = url.absoluteString
            guard seenURLs.insert(key).inserted else { continue }
            uniqueTabs.append(tab)
        }
        let validSelection = uniqueTabs.contains { $0.id == selectedTabID }
        return AppSessionState(
            tabs: uniqueTabs,
            selectedTabID: validSelection ? selectedTabID : AppTab.jobsID
        )
    }
}
