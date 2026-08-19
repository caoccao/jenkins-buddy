import Combine
import SwiftUI

struct ContentView: View {
    let viewModel: AppViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let strings = AppStrings(language: viewModel.settings.resolvedLanguage)
        VStack(spacing: 0) {
            AppToolbar(
                isRefreshing: viewModel.isLoadingJobs,
                jobURL: viewModel.selectedTab.jobURL,
                jobDetailViewMode: viewModel.settings.state.jobDetailViewMode,
                strings: strings,
                onRefresh: { Task { await viewModel.refreshSelected() } },
                onJobDetailViewModeChange: { mode in
                    viewModel.settings.update { $0.jobDetailViewMode = mode }
                },
                onSettings: { SettingsWindowRoute.open(using: openWindow) }
            )
            TabsBar(
                tabs: viewModel.openTabs,
                selectedTabID: viewModel.tabCollection.selectedTabID,
                statuses: viewModel.snapshots.mapValues(\.status),
                strings: strings,
                onSelect: { id in Task { await viewModel.select(tabID: id) } },
                onClose: { id in Task { await viewModel.close(tabID: id) } }
            )

            selectedContent(strings: strings)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            AppStatusBar(
                connectionState: viewModel.connectionState,
                monitoredJobCount: viewModel.openTabs.filter { $0.kind == .job }.count,
                strings: strings
            )
        }
        .frame(
            minWidth: AppLayout.minimumWindowWidth,
            minHeight: AppLayout.minimumWindowHeight
        )
        .environment(\.locale, viewModel.settings.resolvedLanguage.locale)
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onReceive(NotificationCenter.default.publisher(for: .refreshJenkinsBuddy)) { _ in
            viewModel.restartPolling()
            Task { await viewModel.refreshAll() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .jenkinsBuddyConnectionChanged)) { _ in
            Task { await viewModel.connectionDidChange() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openJenkinsBuddyJob)) { notification in
            guard let event = notification.object as? OpenJobEvent else { return }
            Task { await viewModel.open(jobURL: event.jobURL, title: event.jobName) }
        }
    }

    @ViewBuilder
    private func selectedContent(strings: AppStrings) -> some View {
        let tab = viewModel.selectedTab
        switch tab.kind {
        case .jobs:
            JobsView(
                jobs: viewModel.jobs,
                isLoading: viewModel.isLoadingJobs,
                isLoadingSearch: viewModel.isLoadingSearch,
                isConfigured: viewModel.connectionState != .notConfigured,
                viewModel: viewModel.jobsViewModel,
                strings: strings,
                onOpen: { job in Task { await viewModel.open(job) } },
                onExpand: { job in Task { await viewModel.loadChildren(for: job) } },
                onSearch: { await viewModel.loadJobsForSearch() },
                onSettings: { SettingsWindowRoute.open(using: openWindow) },
                onRetry: { Task { await viewModel.refreshJobs() } }
            )
        case .job:
            JobDetailView(
                tab: tab,
                snapshot: tab.jobURL.flatMap { viewModel.snapshots[$0] },
                viewMode: viewModel.settings.state.jobDetailViewMode,
                strings: strings,
                onRetry: { Task { await viewModel.refreshSelected() } }
            )
        }
    }
}
