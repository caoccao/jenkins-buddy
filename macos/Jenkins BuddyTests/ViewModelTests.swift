import Foundation
import Testing
@testable import Jenkins_Buddy

@Suite("View models", .serialized)
@MainActor
struct ViewModelTests {
    private func configuredSettings(interval: Double = 30) -> AppSettings {
        let settings = AppSettings(storage: MemorySettingsStorage(), storageKey: UUID().uuidString)
        settings.update {
            $0.jenkins.serverURL = Samples.baseURL.absoluteString
            $0.jenkins.username = "developer"
            $0.jenkins.refreshInterval = interval
        }
        return settings
    }

    @Test("Jobs search keeps matching parents and descendants")
    func jobsFiltering() {
        let child = Samples.job(name: "ios-release", url: Samples.jobURL)
        let folder = Samples.job(name: "mobile", url: Samples.secondJobURL, children: [child])
        let other = Samples.job(name: "backend", url: Samples.url("https://example.com/backend"))
        let viewModel = JobsViewModel()
        #expect(viewModel.filteredJobs([folder, other]).count == 2)
        viewModel.searchText = "ios"
        let childMatch = viewModel.filteredJobs([folder, other])
        #expect(childMatch.count == 1)
        #expect(childMatch.first?.children.count == 1)
        #expect(childMatch.first?.isContainer == folder.isContainer)
        #expect(childMatch.first?.buildable == folder.buildable)
        viewModel.searchText = "mobile"
        #expect(viewModel.filteredJobs([folder]).first?.children.count == 1)
        #expect(viewModel.isSearching)
        viewModel.searchText = "missing"
        #expect(viewModel.filteredJobs([folder, other]).isEmpty)
        viewModel.searchText = "   "
        #expect(!viewModel.isSearching)
    }

    @Test("Jenkins settings test and save valid credentials")
    func jenkinsSettingsSuccess() async throws {
        let settings = configuredSettings()
        let credentials = MemoryCredentialStore(token: "old")
        let service = StubJenkinsService(jobsResult: .success([Samples.job()]))
        let viewModel = JenkinsSettingsViewModel(settings: settings, credentials: credentials, jenkins: service)
        #expect(viewModel.token == "old")
        #expect(viewModel.canSubmit)
        #expect(!viewModel.connectionIdentityChanged)
        viewModel.username = "other"
        #expect(viewModel.connectionIdentityChanged)
        viewModel.username = "developer"
        viewModel.token = "new"
        viewModel.refreshInterval = 1
        await viewModel.testConnection()
        #expect(viewModel.testState == .success)
        #expect(viewModel.save())
        #expect(viewModel.didSave)
        #expect(try credentials.token(for: Samples.credentialKey()) == "new")
        #expect(settings.state.jenkins.refreshInterval == 5)
    }

    @Test("Jenkins settings expose validation and connection failures")
    func jenkinsSettingsFailure() async {
        let settings = AppSettings(storage: MemorySettingsStorage(), storageKey: UUID().uuidString)
        let credentials = MemoryCredentialStore()
        let service = StubJenkinsService(jobsResult: .failure(JenkinsClientError.forbidden))
        let viewModel = JenkinsSettingsViewModel(settings: settings, credentials: credentials, jenkins: service)
        #expect(!viewModel.canSubmit)
        viewModel.serverURL = "https://example.com"
        viewModel.username = "user"
        viewModel.token = "token"
        #expect(viewModel.canSubmit)
        await viewModel.testConnection()
        if case .failure = viewModel.testState {} else {
            Issue.record("Expected a failed connection test")
        }
        viewModel.serverURL = "invalid"
        #expect(!viewModel.save())
        #expect(!viewModel.didSave)
    }

    @Test("Unconfigured app remains on the Jobs tab")
    func appNotConfigured() async {
        let settings = AppSettings(storage: MemorySettingsStorage(), storageKey: UUID().uuidString)
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(),
            jenkins: StubJenkinsService(),
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore()
        )
        await viewModel.start()
        #expect(viewModel.connectionState == .notConfigured)
        #expect(viewModel.jobs.isEmpty)
        #expect(viewModel.openTabs == [.jobs])
        #expect(!(await viewModel.pollOpenJobs()))
        viewModel.stop()
    }

    @Test("App restores tabs, refreshes jobs, selects, and closes")
    func appTabsAndRefresh() async {
        let settings = configuredSettings(interval: 3_600)
        let tab = AppTab.job(title: "mobile", url: Samples.jobURL)
        let stored = AppSessionState(tabs: [.jobs, tab], selectedTabID: tab.id)
        let service = SequencedJenkinsService(
            jobs: [.success([Samples.job()]), .success([Samples.job()])],
            snapshots: [Samples.jobURL: [.success(Samples.snapshot()), .success(Samples.snapshot())]]
        )
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore(state: stored)
        )
        await viewModel.start()
        #expect(viewModel.selectedTab.id == tab.id)
        #expect(viewModel.jobs.count == 1)
        #expect(viewModel.snapshots[Samples.jobURL]?.name == "mobile")
        #expect(viewModel.connectionState == .online)

        await viewModel.select(tabID: AppTab.jobsID)
        #expect(viewModel.selectedTab.kind == .jobs)
        await viewModel.open(Samples.job())
        #expect(viewModel.openTabs.count == 2)
        await viewModel.refreshSelected()
        await viewModel.close(tabID: tab.id)
        #expect(viewModel.openTabs == [.jobs])
        #expect(viewModel.snapshots[Samples.jobURL] == nil)
        await viewModel.open(jobURL: Samples.secondJobURL, title: "backend")
        #expect(viewModel.selectedTab.jobURL == Samples.secondJobURL)
        await viewModel.connectionDidChange()
        #expect(viewModel.openTabs == [.jobs])
        #expect(viewModel.snapshots.isEmpty)
        viewModel.stop()
    }

    @Test("App persists per-tab view modes and dragged job order")
    func appTabPreferencesAndOrder() async {
        let first = Samples.job()
        let second = Samples.job(name: "backend", url: Samples.secondJobURL)
        let store = MemoryAppStateStore()
        let viewModel = AppViewModel(
            settings: configuredSettings(),
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: StubJenkinsService(
                jobsResult: .success([first, second]),
                snapshots: [
                    first.url: .success(Samples.snapshot()),
                    second.url: .success(Samples.snapshot(name: "backend", url: second.url))
                ]
            ),
            notifications: MemoryNotificationService(),
            stateStore: store
        )

        await viewModel.refreshJobs()
        await viewModel.open(first)
        let firstID = viewModel.selectedTab.id
        await viewModel.open(second)
        let secondID = viewModel.selectedTab.id
        await viewModel.setJobDetailViewMode(.card, for: firstID)
        await viewModel.move(tabID: firstID, to: secondID)

        #expect(viewModel.openTabs.compactMap(\.jobURL) == [second.url, first.url])
        #expect(viewModel.openTabs.first { $0.id == firstID }?.jobDetailViewMode == .card)
        #expect(!viewModel.isRefreshingSelectedTab)
        let persisted = await store.load()
        #expect(persisted.tabs.compactMap(\.jobURL) == [second.url, first.url])
        #expect(persisted.tabs.first { $0.id == firstID }?.jobDetailViewMode == .card)
        viewModel.stop()
    }

    @Test("App records a silent baseline then delivers selected events")
    func appNotifications() async throws {
        let settings = configuredSettings()
        settings.update {
            $0.notifications.isEnabled = true
            $0.notifications.buildStarted = true
        }
        let notifications = MemoryNotificationService()
        let service = SequencedJenkinsService(
            jobs: [.success([Samples.job()])],
            snapshots: [Samples.jobURL: [
                .success(Samples.snapshot(number: 1)),
                .success(Samples.snapshot(number: 2, result: nil, building: true)),
                .success(Samples.snapshot(number: 2, result: "FAILURE"))
            ]]
        )
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: notifications,
            stateStore: MemoryAppStateStore()
        )
        await viewModel.refreshJobs()
        await viewModel.open(Samples.job())
        #expect(await notifications.recordedDeliveries().isEmpty)
        #expect(await viewModel.pollOpenJobs())
        #expect(await notifications.recordedDeliveries().first?.event.kind == .started)
        #expect(await viewModel.pollOpenJobs())
        #expect(await notifications.recordedDeliveries().last?.event.kind == .failed)
        #expect(await notifications.recordedDeliveries().last?.body.contains("Build #2") == true)
        viewModel.stop()
    }

    @Test("App reports Jenkins failures without dropping prior data")
    func appFailure() async {
        let settings = configuredSettings()
        let service = SequencedJenkinsService(
            jobs: [.success([Samples.job()]), .failure(JenkinsClientError.server(503))],
            snapshots: [Samples.jobURL: [.failure(JenkinsClientError.notFound)]]
        )
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore()
        )
        await viewModel.refreshJobs()
        #expect(viewModel.jobs.count == 1)
        await viewModel.refreshJobs()
        if case .offline = viewModel.connectionState {} else {
            Issue.record("Expected offline state")
        }
        await viewModel.open(Samples.job())
        if case .offline = viewModel.connectionState {} else {
            Issue.record("Expected job refresh failure")
        }
        #expect(!(await viewModel.pollOpenJobs()))
        viewModel.restartPolling()
        viewModel.stop()
    }

    @Test("Expanding a container lazily loads its direct children")
    func lazyFolderLoading() async {
        let settings = configuredSettings()
        let folder = JenkinsJob(
            name: "edge-composite",
            fullName: "HiveMQ4/edge-composite",
            url: Samples.secondJobURL,
            color: nil,
            objectClass: "org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject",
            buildable: true,
            children: []
        )
        let child = Samples.job()
        let service = StubJenkinsService(
            jobsResult: .success([folder]),
            children: [folder.url: .success([child])]
        )
        let staleContainerTab = AppTab.job(title: folder.name, url: folder.url)
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore(
                state: AppSessionState(
                    tabs: [.jobs, staleContainerTab],
                    selectedTabID: staleContainerTab.id
                )
            )
        )
        await viewModel.start()
        #expect(viewModel.openTabs == [.jobs])
        await viewModel.open(folder)
        #expect(viewModel.openTabs == [.jobs])
        await viewModel.loadChildren(for: folder)
        #expect(viewModel.jobs.first?.children == [child])
        await viewModel.loadChildren(for: child)
        viewModel.stop()
    }

    @Test("Searching actively loads every container level")
    func activeRecursiveSearchLoading() async {
        let settings = configuredSettings()
        let folder = JenkinsJob(
            name: "HiveMQ4",
            fullName: "HiveMQ4",
            url: Samples.secondJobURL,
            color: nil,
            objectClass: "com.cloudbees.hudson.plugins.folder.Folder",
            children: []
        )
        let projectURL = Samples.url("https://jenkins.example.com/jenkins/job/backend/job/edge-composite/")
        let project = JenkinsJob(
            name: "edge-composite",
            fullName: "HiveMQ4/edge-composite",
            url: projectURL,
            color: nil,
            objectClass: "org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject",
            buildable: true,
            children: []
        )
        let branch = JenkinsJob(
            name: "bugfix%2FEDG-835%2Fallow-null-in-comment",
            fullName: "HiveMQ4/edge-composite/bugfix%2FEDG-835%2Fallow-null-in-comment",
            url: Samples.jobURL,
            color: "blue",
            objectClass: "org.jenkinsci.plugins.workflow.job.WorkflowJob",
            buildable: true,
            children: []
        )
        let service = StubJenkinsService(
            jobsResult: .success([folder]),
            children: [folder.url: .success([project]), project.url: .success([branch])]
        )
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore()
        )
        await viewModel.refreshJobs()
        viewModel.jobsViewModel.searchText = "allow-null"
        await viewModel.loadJobsForSearch()

        #expect(viewModel.jobs.first?.children.first?.children == [branch])
        #expect(viewModel.jobsViewModel.filteredJobs(viewModel.jobs).first?.children.first?.children == [branch])
        #expect(!viewModel.isLoadingSearch)
        #expect(viewModel.connectionState == .online)
        viewModel.stop()
    }

    @Test("A mismatched snapshot is never shown in another job tab")
    func mismatchedSnapshotIsRejected() async {
        let settings = configuredSettings()
        let service = SequencedJenkinsService(
            jobs: [.success([Samples.job()])],
            snapshots: [Samples.jobURL: [.success(Samples.snapshot(name: "backend", url: Samples.secondJobURL))]]
        )
        let viewModel = AppViewModel(
            settings: settings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: service,
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore()
        )
        await viewModel.refreshJobs()
        await viewModel.open(Samples.job())

        #expect(viewModel.selectedTab.jobURL == Samples.jobURL)
        #expect(viewModel.snapshots[Samples.jobURL] == nil)
        if case .offline = viewModel.connectionState {} else {
            Issue.record("Expected a mismatched snapshot to fail the refresh")
        }
        viewModel.stop()
    }
}
