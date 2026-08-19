import SwiftUI

struct JobDetailView: View {
    let tab: AppTab
    let snapshot: JobSnapshot?
    let viewMode: JobDetailViewMode
    let strings: AppStrings
    let onRetry: () -> Void

    var body: some View {
        if let snapshot {
            ScrollView {
                VStack(alignment: .leading, spacing: UIConstants.JobDetail.sectionSpacing) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: UIConstants.JobDetail.titleSpacing) {
                            Text(snapshot.displayName)
                                .font(.largeTitle.weight(.semibold))
                            Link(snapshot.url.host() ?? snapshot.url.absoluteString, destination: snapshot.url)
                                .font(.caption)
                        }
                        Spacer()
                        StatusBadge(status: snapshot.status, strings: strings)
                    }

                    if let description = snapshot.description, !description.isEmpty {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }

                    Grid(
                        alignment: .leading,
                        horizontalSpacing: UIConstants.JobDetail.metadataHorizontalSpacing,
                        verticalSpacing: UIConstants.JobDetail.metadataVerticalSpacing
                    ) {
                        GridRow {
                            Text(strings[.inQueue]).foregroundStyle(.secondary)
                            Text(snapshot.inQueue ? strings[.yes] : strings[.no])
                        }
                        GridRow {
                            Text(strings[.status]).foregroundStyle(.secondary)
                            Text(strings.status(snapshot.status))
                        }
                    }

                    buildContent(snapshot)
                }
                .padding(AppLayout.contentPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityIdentifier("job-detail")
        } else {
            ContentUnavailableView {
                Label(strings[.loadingJob], systemImage: "hammer")
            } description: {
                Text(tab.title)
            } actions: {
                Button(strings[.retry], action: onRetry)
            }
        }
    }

    @ViewBuilder
    private func buildContent(_ snapshot: JobSnapshot) -> some View {
        switch viewMode {
        case .detail:
            BuildDetailsView(snapshot: snapshot, strings: strings)
        case .card:
            if snapshot.buildHistory.isEmpty {
                Text(strings[.noBuilds])
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(
                            .adaptive(minimum: UIConstants.JobDetail.cardMinimumWidth),
                            spacing: UIConstants.JobDetail.cardSpacing
                        )
                    ],
                    spacing: UIConstants.JobDetail.cardSpacing
                ) {
                    ForEach(snapshot.buildHistory, id: \.number) { build in
                        BuildSummaryView(build: build, strings: strings)
                    }
                }
            }
        }
    }
}
