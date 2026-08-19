import SwiftUI

struct BuildSummaryView: View {
    let build: JenkinsBuild
    let strings: AppStrings
    @Environment(\.locale) private var locale

    var body: some View {
        GroupBox {
            Grid(
                alignment: .leading,
                horizontalSpacing: UIConstants.JobDetail.cardContentColumnSpacing,
                verticalSpacing: UIConstants.JobDetail.cardContentRowSpacing
            ) {
                GridRow {
                    Text(strings[.status]).foregroundStyle(.secondary)
                    StatusBadge(status: build.status, strings: strings)
                }
                GridRow {
                    Text(strings[.startedAt]).foregroundStyle(.secondary)
                    Text(BuildFormatting.date(build.startedAt, locale: locale))
                }
                GridRow {
                    Text(strings[.duration]).foregroundStyle(.secondary)
                    Text(BuildFormatting.duration(milliseconds: build.duration, locale: locale))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Link("\(strings[.buildNumber]) #\(build.number)", destination: build.url)
                .font(.headline)
        }
    }
}
