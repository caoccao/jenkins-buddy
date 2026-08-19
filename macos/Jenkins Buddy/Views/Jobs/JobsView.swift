import SwiftUI

struct JobsView: View {
    let jobs: [JenkinsJob]
    let isLoading: Bool
    let isLoadingSearch: Bool
    let isConfigured: Bool
    let viewModel: JobsViewModel
    let strings: AppStrings
    let onOpen: (JenkinsJob) -> Void
    let onExpand: (JenkinsJob) -> Void
    let onSearch: () async -> Void
    let onSettings: () -> Void
    let onRetry: () -> Void

    var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            if showsJobBrowser {
                VStack(spacing: 0) {
                    searchBar(searchText: $viewModel.searchText)
                    JobsTreeView(
                        jobs: viewModel.filteredJobs(jobs),
                        expandContainers: viewModel.isSearching,
                        strings: strings,
                        onOpen: onOpen,
                        onExpand: onExpand
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                stateContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: viewModel.normalizedSearchText) {
            guard viewModel.isSearching else { return }
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await onSearch()
        }
    }

    var showsJobBrowser: Bool {
        isConfigured && !jobs.isEmpty
    }

    @ViewBuilder
    private var stateContent: some View {
        if !isConfigured {
            ContentUnavailableView {
                Label(strings[.jenkins], systemImage: "gearshape.2")
            } description: {
                Text(strings[.configureJenkins])
            } actions: {
                Button(strings[.openSettings], action: onSettings)
            }
        } else if isLoading && jobs.isEmpty {
            ProgressView(strings[.loadingJobs])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if jobs.isEmpty {
            ContentUnavailableView {
                Label(strings[.jobs], systemImage: "tray")
            } description: {
                Text(strings[.noJobs])
            } actions: {
                Button(strings[.retry], action: onRetry)
            }
        }
    }

    private func searchBar(searchText: Binding<String>) -> some View {
        HStack(spacing: UIConstants.Jobs.searchSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(strings[.searchJobs], text: searchText)
                .textFieldStyle(.plain)
                .accessibilityIdentifier("job-search")
            if isLoadingSearch {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, UIConstants.Jobs.searchHorizontalPadding)
        .frame(height: UIConstants.Jobs.searchBarHeight)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }
}
