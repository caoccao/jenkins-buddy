import AppKit
import SwiftUI
import Testing
@testable import Jenkins_Buddy

@Suite("View rendering", .serialized)
@MainActor
struct ViewRenderingTests {
    private func render<Content: View>(_ view: Content, width: CGFloat = 760, height: CGFloat = 520) {
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: width, height: height)
        hostingView.layoutSubtreeIfNeeded()
        hostingView.displayIfNeeded()
        withExtendedLifetime(hostingView) {}
    }

    private func settings() -> AppSettings {
        AppSettings(storage: MemorySettingsStorage(), storageKey: UUID().uuidString)
    }

    @Test("Status controls and palettes render every status")
    func statusControls() {
        let strings = AppStrings(language: .english)
        for status in BuildStatus.allCases {
            _ = StatusColors.color(for: status)
            #expect(!StatusColors.symbol(for: status).isEmpty)
            let badge = StatusBadge(status: status, strings: strings)
            let dot = StatusDot(status: status)
            _ = badge.body
            _ = dot.body
            render(HStack { badge; dot }, width: 280, height: 70)
        }
    }

    @Test("Job rows and recursive trees render leaf and folder states")
    func jobTree() {
        let child = Samples.job(name: "child", url: Samples.jobURL)
        let folder = Samples.job(name: "folder", url: Samples.secondJobURL, children: [child])
        let strings = AppStrings(language: .english)
        let row = JobRow(job: child, strings: strings) {}
        _ = row.body
        render(row, width: 400, height: 80)

        let tree = JobsTreeView(
            jobs: [folder, child],
            expandContainers: false,
            strings: strings,
            onOpen: { _ in },
            onExpand: { _ in }
        )
        _ = tree.body
        render(tree)
    }

    @Test("Jobs page renders configuration, loading, empty, and populated states")
    func jobsStates() {
        let strings = AppStrings(language: .english)
        let jobsViewModel = JobsViewModel()
        let variants = [
            JobsView(
                jobs: [], isLoading: false, isConfigured: false,
                viewModel: jobsViewModel, strings: strings, onOpen: { _ in }, onExpand: { _ in },
                onSearch: {}, onSettings: {}, onRetry: {}
            ),
            JobsView(
                jobs: [], isLoading: true, isConfigured: true,
                viewModel: jobsViewModel, strings: strings, onOpen: { _ in }, onExpand: { _ in },
                onSearch: {}, onSettings: {}, onRetry: {}
            ),
            JobsView(
                jobs: [], isLoading: false, isConfigured: true,
                viewModel: jobsViewModel, strings: strings, onOpen: { _ in }, onExpand: { _ in },
                onSearch: {}, onSettings: {}, onRetry: {}
            ),
            JobsView(
                jobs: [Samples.job()], isLoading: false, isConfigured: true,
                viewModel: jobsViewModel, strings: strings, onOpen: { _ in }, onExpand: { _ in },
                onSearch: {}, onSettings: {}, onRetry: {}
            )
        ]
        #expect(variants.map(\.showsJobBrowser) == [false, false, false, true])
        for view in variants {
            _ = view.body
            render(
                view,
                width: AppLayout.defaultWindowWidth,
                height: AppLayout.defaultWindowHeight
            )
        }
    }

    @Test("Job details render empty and complete build summaries")
    func jobDetails() {
        let strings = AppStrings(language: .english)
        let build = Samples.build()
        let summary = BuildSummaryView(build: build, strings: strings)
        render(summary)

        let snapshot = JobSnapshot(
            name: "mobile",
            url: Samples.jobURL,
            color: "blue",
            description: "Job description",
            buildable: true,
            inQueue: true,
            lastBuild: build,
            lastCompletedBuild: build,
            lastSuccessfulBuild: build,
            lastFailedBuild: Samples.build(number: 41, result: "FAILURE"),
            builds: [Samples.build(number: 41, result: "FAILURE"), build],
            fetchedAt: Date()
        )
        let emptySnapshot = JobSnapshot(
            name: "empty", url: Samples.secondJobURL, color: nil, description: nil,
            buildable: true, inQueue: false, lastBuild: nil, lastCompletedBuild: nil,
            lastSuccessfulBuild: nil, lastFailedBuild: nil, builds: [], fetchedAt: Date()
        )
        let tab = AppTab.job(title: "mobile", url: Samples.jobURL)
        let detail = JobDetailView(tab: tab, snapshot: snapshot, viewMode: .detail, strings: strings) {}
        let cards = JobDetailView(tab: tab, snapshot: snapshot, viewMode: .card, strings: strings) {}
        let loading = JobDetailView(tab: tab, snapshot: nil, viewMode: .detail, strings: strings) {}
        render(BuildDetailsView(snapshot: snapshot, strings: strings), width: 860, height: 260)
        render(BuildDetailsView(snapshot: emptySnapshot, strings: strings), width: 860, height: 180)
        render(detail, width: 900, height: 700)
        render(cards, width: 900, height: 700)
        render(JobDetailView(tab: tab, snapshot: emptySnapshot, viewMode: .card, strings: strings) {})
        render(loading)
    }

    @Test("Jenkins settings renders all connection-test states")
    func jenkinsSettings() {
        let appSettings = settings()
        appSettings.update {
            $0.jenkins.serverURL = Samples.baseURL.absoluteString
            $0.jenkins.username = "developer"
        }
        let viewModel = JenkinsSettingsViewModel(
            settings: appSettings,
            credentials: MemoryCredentialStore(token: "token"),
            jenkins: StubJenkinsService()
        )
        let strings = AppStrings(language: .english)
        for state in [
            JenkinsSettingsViewModel.TestState.idle,
            .testing,
            .success,
            .failure("error")
        ] {
            viewModel.testState = state
            let view = JenkinsSettingsView(viewModel: viewModel, strings: strings)
            _ = view.body
            render(view)
        }
        viewModel.username = "other"
        let warningView = JenkinsSettingsView(viewModel: viewModel, strings: strings)
        _ = warningView.body
        render(warningView)

        for language in AppLanguage.allCases {
            let localizedView = JenkinsSettingsView(
                viewModel: viewModel,
                strings: AppStrings(language: language)
            )
            render(
                localizedView,
                width: AppLayout.settingsContentWidth,
                height: AppLayout.settingsHeight
            )
        }
    }

    @Test("Notification settings binds every event and renders permission states")
    func notificationSettings() async {
        let appSettings = settings()
        let service = MemoryNotificationService()
        let strings = AppStrings(language: .english)
        let view = NotificationSettingsView(
            settings: appSettings,
            notifications: service,
            strings: strings
        )
        let enabled = view.enabledBinding
        enabled.wrappedValue = true
        #expect(appSettings.state.notifications.isEnabled)
        enabled.wrappedValue = false
        #expect(!appSettings.state.notifications.isEnabled)
        view.binding(\.buildStarted).wrappedValue = true
        view.binding(\.buildSucceeded).wrappedValue = false
        view.binding(\.buildFailed).wrappedValue = false
        view.binding(\.playSound).wrappedValue = false
        #expect(appSettings.state.notifications.buildStarted)

        for permission in [nil, true, false] as [Bool?] {
            let variant = NotificationSettingsView(
                settings: appSettings,
                notifications: service,
                strings: strings,
                permissionGranted: permission
            )
            _ = variant.body
            render(variant)
        }
        await view.sendTestNotification()
        #expect(await service.recordedDeliveries().last?.event.jobName == "Jenkins Buddy")
    }

    @Test("Settings split view renders each sidebar destination")
    func settingsRoot() {
        let appSettings = settings()
        for selection in SettingsRootView.Section.allCases {
            let root = SettingsRootView(
                settings: appSettings,
                credentials: MemoryCredentialStore(),
                jenkins: StubJenkinsService(),
                notifications: MemoryNotificationService(),
                selection: selection
            )
            render(root)
        }
    }

    @Test("Language settings renders every live selection")
    func languageSettings() {
        let appSettings = settings()
        for language in AppLanguage.allCases {
            appSettings.update { $0.language = language }
            let strings = AppStrings(language: language)
            let view = LanguageSettingsView(settings: appSettings, strings: strings)
            _ = view.body
            render(view)
            #expect(appSettings.resolvedLanguage == language)
        }
    }

    @Test("Tab bar renders permanent and closable tabs")
    func tabs() {
        let jobTab = AppTab.job(title: "mobile", url: Samples.jobURL)
        let view = TabsBar(
            tabs: [.jobs, jobTab],
            selectedTabID: jobTab.id,
            statuses: [Samples.jobURL: .failure],
            strings: AppStrings(language: .english),
            onSelect: { _ in },
            onClose: { _ in },
            onMove: { _, _ in }
        )
        _ = view.body
        render(view, width: 500, height: 50)
    }

    @Test("Tab toolbars render Jobs and job controls")
    func toolbar() {
        let strings = AppStrings(language: .english)
        let jobToolbar = TabToolbar(
            isRefreshing: true,
            showsViewModeControls: true,
            searchText: nil,
            isLoadingSearch: false,
            jobDetailViewMode: .detail,
            strings: strings,
            onRefresh: {},
            onJobDetailViewModeChange: { _ in }
        )
        let jobsToolbar = TabToolbar(
            isRefreshing: false,
            showsViewModeControls: false,
            searchText: .constant("mobile"),
            isLoadingSearch: true,
            jobDetailViewMode: .card,
            strings: strings,
            onRefresh: {},
            onJobDetailViewModeChange: { _ in }
        )
        _ = jobToolbar.body
        _ = jobsToolbar.body
        render(jobToolbar, width: 500, height: 50)
        render(jobsToolbar, width: 500, height: 50)
    }

    @Test("Content shell renders a restored job tab")
    func jobContentShell() async {
        let appSettings = settings()
        appSettings.update {
            $0.jenkins.serverURL = Samples.baseURL.absoluteString
            $0.jenkins.username = "developer"
        }
        let tab = AppTab.job(title: "mobile", url: Samples.jobURL)
        let viewModel = AppViewModel(
            settings: appSettings,
            credentials: MemoryCredentialStore(token: "secret"),
            jenkins: StubJenkinsService(
                jobsResult: .success([Samples.job()]),
                snapshots: [Samples.jobURL: .success(Samples.snapshot())]
            ),
            notifications: MemoryNotificationService(),
            stateStore: MemoryAppStateStore(
                state: AppSessionState(tabs: [.jobs, tab], selectedTabID: tab.id)
            )
        )
        await viewModel.start()
        let view = ContentView(viewModel: viewModel)
        _ = view.body
        render(view, width: 920, height: 640)
        viewModel.stop()
    }

}
