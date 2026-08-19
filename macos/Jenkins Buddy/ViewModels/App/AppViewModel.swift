import Foundation
import Observation

@MainActor
@Observable
final class AppViewModel {
    enum ConnectionState: Equatable {
        case notConfigured
        case loading
        case online
        case offline(String)
    }

    private(set) var tabCollection = TabCollection()
    private(set) var jobs: [JenkinsJob] = []
    private(set) var snapshots: [URL: JobSnapshot] = [:]
    private(set) var connectionState = ConnectionState.notConfigured
    private(set) var isLoadingJobs = false
    private(set) var isLoadingSearch = false
    private(set) var refreshingJobURLs = Set<URL>()

    let jobsViewModel = JobsViewModel()
    let settings: AppSettings
    let credentials: any CredentialStore
    let jenkins: any JenkinsServing
    let notifications: any NotificationDelivering

    private let stateStore: any AppStateStore
    private let monitor: JobMonitor
    private var pollingTask: Task<Void, Never>?
    private var loadedContainerURLs = Set<URL>()

    init(
        settings: AppSettings,
        credentials: any CredentialStore,
        jenkins: any JenkinsServing,
        notifications: any NotificationDelivering,
        stateStore: any AppStateStore,
        monitor: JobMonitor = JobMonitor()
    ) {
        self.settings = settings
        self.credentials = credentials
        self.jenkins = jenkins
        self.notifications = notifications
        self.stateStore = stateStore
        self.monitor = monitor
    }

    var selectedTab: AppTab { tabCollection.selectedTab }
    var openTabs: [AppTab] { tabCollection.tabs }
    var isRefreshingSelectedTab: Bool {
        guard let jobURL = selectedTab.jobURL else { return isLoadingJobs }
        return refreshingJobURLs.contains(jobURL)
    }

    func start() async {
        if let restored = try? await stateStore.load() {
            tabCollection = TabCollection(state: restored)
        }
        await refreshAll()
        restartPolling()
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func refreshAll() async {
        await refreshJobs()
        await refreshOpenJobs()
    }

    func refreshJobs() async {
        guard let connection = connection() else {
            jobs = []
            loadedContainerURLs = []
            connectionState = .notConfigured
            return
        }
        isLoadingJobs = true
        connectionState = .loading
        defer { isLoadingJobs = false }
        do {
            let refreshedJobs = try await jenkins.fetchJobs(connection: connection)
            jobs = merge(refreshed: refreshedJobs, existing: jobs)
            await removeContainerTabs()
            connectionState = .online
        } catch {
            connectionState = .offline(error.localizedDescription)
        }
    }

    func open(_ job: JenkinsJob) async {
        guard !job.isContainer else { return }
        tabCollection.open(job: job)
        await persistTabs()
        _ = await refresh(jobURL: job.url)
        await updateMonitorScope()
    }

    func loadChildren(for container: JenkinsJob) async {
        guard container.isContainer, let connection = connection() else { return }
        do {
            _ = try await children(for: container, connection: connection)
            await removeContainerTabs()
            connectionState = .online
        } catch {
            guard !Task.isCancelled else { return }
            connectionState = .offline(error.localizedDescription)
        }
    }

    func loadJobsForSearch() async {
        guard !isLoadingSearch, let connection = connection() else { return }
        isLoadingSearch = true
        defer { isLoadingSearch = false }
        do {
            try await loadDescendants(in: jobs, connection: connection)
            await removeContainerTabs()
            connectionState = .online
        } catch {
            guard !Task.isCancelled else { return }
            connectionState = .offline(error.localizedDescription)
        }
    }

    func open(jobURL: URL, title: String) async {
        let knownJob = flattened(jobs).first { $0.url == jobURL }
            ?? JenkinsJob(
                name: title,
                fullName: title,
                url: jobURL,
                color: nil,
                buildable: true,
                children: []
            )
        await open(knownJob)
    }

    func select(tabID: UUID) async {
        tabCollection.select(tabID)
        await persistTabs()
    }

    func close(tabID: UUID) async {
        let url = tabCollection.tabs.first { $0.id == tabID }?.jobURL
        tabCollection.close(tabID)
        if let url, !tabCollection.tabs.contains(where: { $0.jobURL == url }) {
            snapshots[url] = nil
        }
        await persistTabs()
        await updateMonitorScope()
    }

    func setJobDetailViewMode(_ mode: JobDetailViewMode, for tabID: UUID) async {
        tabCollection.setJobDetailViewMode(mode, for: tabID)
        await persistTabs()
    }

    func move(tabID: UUID, to targetID: UUID) async {
        tabCollection.move(tabID, to: targetID)
        await persistTabs()
    }

    func refreshSelected() async {
        if let url = selectedTab.jobURL {
            _ = await refresh(jobURL: url)
        } else {
            await refreshJobs()
        }
    }

    func restartPolling() {
        pollingTask?.cancel()
        let interval = settings.state.jenkins.refreshInterval
        pollingTask = Task { [weak self] in
            var failureCount = 0
            while !Task.isCancelled {
                guard let self else { return }
                let succeeded = await self.pollOpenJobs()
                failureCount = succeeded ? 0 : failureCount + 1
                let delay = PollingBackoff(baseInterval: interval)
                    .delay(afterConsecutiveFailures: failureCount)
                try? await Task.sleep(for: .seconds(delay))
            }
        }
    }

    func connectionDidChange() async {
        stop()
        tabCollection = TabCollection()
        jobs = []
        snapshots = [:]
        refreshingJobURLs = []
        loadedContainerURLs = []
        connectionState = .loading
        await monitor.reset()
        await persistTabs()
        await refreshAll()
        restartPolling()
    }

    @discardableResult
    func pollOpenJobs() async -> Bool {
        guard connection() != nil else { return false }
        let urls = tabCollection.tabs.compactMap(\.jobURL)
        var succeeded = true
        for url in urls {
            if !(await refresh(jobURL: url)) { succeeded = false }
        }
        return succeeded
    }

    private func refreshOpenJobs() async {
        for url in tabCollection.tabs.compactMap(\.jobURL) {
            _ = await refresh(jobURL: url)
        }
        await updateMonitorScope()
    }

    @discardableResult
    private func refresh(jobURL: URL) async -> Bool {
        guard let connection = connection() else { return false }
        refreshingJobURLs.insert(jobURL)
        defer { refreshingJobURLs.remove(jobURL) }
        do {
            let snapshot = try await jenkins.fetchJob(url: jobURL, connection: connection)
            guard JenkinsResourceIdentity.matches(jobURL, snapshot.url) else {
                throw JenkinsClientError.invalidPayload
            }
            snapshots[jobURL] = snapshot
            connectionState = .online
            let events = await monitor.record(snapshot)
            await deliver(events)
            return true
        } catch {
            if error as? JenkinsClientError == .invalidPayload {
                snapshots[jobURL] = nil
            }
            connectionState = .offline(error.localizedDescription)
            return false
        }
    }

    private func deliver(_ events: [BuildEvent]) async {
        let notificationSettings = settings.state.notifications
        let strings = AppStrings(language: settings.resolvedLanguage)
        for event in events where notificationSettings.allows(event.kind) {
            let eventName = strings.event(event.kind)
            let body = if let number = event.buildNumber {
                strings.formatted(.notificationBuildWithNumber, number, eventName)
            } else {
                strings.formatted(.notificationBuildWithoutNumber, eventName)
            }
            try? await notifications.deliver(
                event,
                title: event.jobName,
                body: body,
                playSound: notificationSettings.playSound
            )
        }
    }

    private func connection() -> JenkinsConnection? {
        guard let identity = try? JenkinsConnection(
            serverURL: settings.state.jenkins.serverURL,
            username: settings.state.jenkins.username,
            token: ""
        ), let token = try? credentials.token(for: identity.credentialKey) else { return nil }
        return try? JenkinsConnection(
            serverURL: identity.baseURL.absoluteString,
            username: identity.username,
            token: token
        )
    }

    private func persistTabs() async {
        try? await stateStore.save(tabCollection.state)
    }

    private func updateMonitorScope() async {
        let urls = Set(tabCollection.tabs.compactMap(\.jobURL))
        await monitor.remove(urlsToKeep: urls)
    }

    private func removeContainerTabs() async {
        let containerURLs = Set(flattened(jobs).filter(\.isContainer).map(\.url))
        let containerTabs = tabCollection.tabs.filter { tab in
            tab.jobURL.map(containerURLs.contains) ?? false
        }
        guard !containerTabs.isEmpty else { return }
        for tab in containerTabs {
            tabCollection.close(tab.id)
            if let jobURL = tab.jobURL {
                snapshots[jobURL] = nil
            }
        }
        await persistTabs()
        await updateMonitorScope()
    }

    private func flattened(_ jobs: [JenkinsJob]) -> [JenkinsJob] {
        jobs.flatMap { [$0] + flattened($0.children) }
    }

    private func loadDescendants(
        in candidates: [JenkinsJob],
        connection: JenkinsConnection
    ) async throws {
        for container in candidates where container.isContainer {
            try Task.checkCancellation()
            let descendants = try await children(for: container, connection: connection)
            try await loadDescendants(in: descendants, connection: connection)
        }
    }

    private func children(
        for container: JenkinsJob,
        connection: JenkinsConnection
    ) async throws -> [JenkinsJob] {
        if loadedContainerURLs.contains(container.url) {
            return flattened(jobs).first { $0.url == container.url }?.children ?? container.children
        }
        if !container.children.isEmpty {
            loadedContainerURLs.insert(container.url)
            return container.children
        }
        let children = try await jenkins.fetchChildren(
            containerURL: container.url,
            connection: connection
        )
        loadedContainerURLs.insert(container.url)
        jobs = replacingChildren(of: container.url, with: children, in: jobs)
        return children
    }

    private func merge(refreshed: [JenkinsJob], existing: [JenkinsJob]) -> [JenkinsJob] {
        let existingByURL = Dictionary(uniqueKeysWithValues: existing.map { ($0.url, $0) })
        return refreshed.map { job in
            guard let oldJob = existingByURL[job.url], job.children.isEmpty else { return job }
            return JenkinsJob(
                name: job.name,
                fullName: job.fullName,
                url: job.url,
                color: job.color,
                objectClass: job.objectClass,
                buildable: job.buildable,
                children: oldJob.children
            )
        }
    }

    private func replacingChildren(
        of containerURL: URL,
        with children: [JenkinsJob],
        in jobs: [JenkinsJob]
    ) -> [JenkinsJob] {
        jobs.map { job in
            if job.url == containerURL {
                return JenkinsJob(
                    name: job.name,
                    fullName: job.fullName,
                    url: job.url,
                    color: job.color,
                    objectClass: job.objectClass,
                    buildable: job.buildable,
                    children: children
                )
            }
            guard !job.children.isEmpty else { return job }
            return JenkinsJob(
                name: job.name,
                fullName: job.fullName,
                url: job.url,
                color: job.color,
                objectClass: job.objectClass,
                buildable: job.buildable,
                children: replacingChildren(of: containerURL, with: children, in: job.children)
            )
        }
    }
}
