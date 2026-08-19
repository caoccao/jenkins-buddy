import Combine
import SwiftUI

struct ContentView: View {
    let viewModel: AppViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let strings = AppStrings(language: viewModel.settings.resolvedLanguage)
        VStack(spacing: 0) {
            TabsBar(
                tabs: viewModel.openTabs,
                selectedTabID: viewModel.tabCollection.selectedTabID,
                statuses: viewModel.snapshots.mapValues(\.status),
                strings: strings,
                onSelect: { id in Task { await viewModel.select(tabID: id) } },
                onClose: { id in Task { await viewModel.close(tabID: id) } },
                onMove: { id, targetID in
                    Task { await viewModel.move(tabID: id, to: targetID) }
                }
            )
            TabToolbar(
                isRefreshing: viewModel.isRefreshingSelectedTab,
                showsViewModeControls: viewModel.selectedTab.kind == .job,
                searchText: searchBinding,
                isLoadingSearch: viewModel.isLoadingSearch,
                jobDetailViewMode: viewModel.selectedTab.jobDetailViewMode,
                strings: strings,
                onRefresh: { Task { await viewModel.refreshSelected() } },
                onJobDetailViewModeChange: { mode in
                    let tabID = viewModel.selectedTab.id
                    Task { await viewModel.setJobDetailViewMode(mode, for: tabID) }
                }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    SettingsWindowRoute.open(using: openWindow)
                } label: {
                    Image(systemName: "gearshape")
                }
                .help(strings[.settings])
                .accessibilityLabel(strings[.settings])
                .accessibilityIdentifier("settings-button")
            }
        }
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
                viewMode: tab.jobDetailViewMode,
                strings: strings,
                onRetry: { Task { await viewModel.refreshSelected() } }
            )
        }
    }

    private var searchBinding: Binding<String>? {
        guard viewModel.selectedTab.kind == .jobs else { return nil }
        return Binding(
            get: { viewModel.jobsViewModel.searchText },
            set: { viewModel.jobsViewModel.searchText = $0 }
        )
    }
}
