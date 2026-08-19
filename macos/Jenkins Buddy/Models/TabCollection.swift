import Foundation

nonisolated struct TabCollection: Equatable, Sendable {
    private(set) var tabs: [AppTab]
    private(set) var selectedTabID: UUID

    init(state: AppSessionState = .initial) {
        let normalized = state.normalized()
        tabs = normalized.tabs
        selectedTabID = normalized.selectedTabID
    }

    var selectedTab: AppTab {
        tabs.first { $0.id == selectedTabID } ?? .jobs
    }

    var state: AppSessionState {
        AppSessionState(tabs: tabs, selectedTabID: selectedTabID)
    }

    mutating func select(_ id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        selectedTabID = id
    }

    @discardableResult
    mutating func open(job: JenkinsJob) -> UUID {
        if let existing = tabs.first(where: { $0.jobURL == job.url }) {
            selectedTabID = existing.id
            return existing.id
        }
        let tab = AppTab.job(title: job.displayName, url: job.url)
        tabs.append(tab)
        selectedTabID = tab.id
        return tab.id
    }

    mutating func close(_ id: UUID) {
        guard id != AppTab.jobsID, let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        let wasSelected = selectedTabID == id
        tabs.remove(at: index)
        guard wasSelected else { return }
        if index < tabs.count {
            selectedTabID = tabs[index].id
        } else {
            selectedTabID = tabs[max(0, index - 1)].id
        }
    }
}
