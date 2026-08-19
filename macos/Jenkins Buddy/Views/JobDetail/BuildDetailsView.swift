import SwiftUI

struct BuildDetailsView: View {
    let snapshot: JobSnapshot
    let strings: AppStrings
    @Environment(\.locale) private var locale

    var body: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: UIConstants.JobDetail.detailColumnSpacing,
            verticalSpacing: UIConstants.JobDetail.detailRowSpacing
        ) {
            GridRow {
                Text(strings[.buildNumber])
                Text(strings[.status])
                Text(strings[.startedAt])
                Text(strings[.duration])
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

            Divider().gridCellColumns(4)
            if snapshot.buildHistory.isEmpty {
                Text(strings[.noBuilds])
                    .foregroundStyle(.secondary)
                    .gridCellColumns(4)
            } else {
                ForEach(snapshot.buildHistory, id: \.number) { build in
                    buildRow(build)
                }
            }
        }
        .padding(UIConstants.JobDetail.detailPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.JobDetail.detailCornerRadius))
    }

    @ViewBuilder
    private func buildRow(_ build: JenkinsBuild) -> some View {
        GridRow {
            Link("#\(build.number)", destination: build.url)
            StatusBadge(status: build.status, strings: strings)
            Text(BuildFormatting.date(build.startedAt, locale: locale))
            Text(BuildFormatting.duration(milliseconds: build.duration, locale: locale))
        }
    }
}
