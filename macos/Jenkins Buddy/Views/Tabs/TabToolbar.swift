import SwiftUI

struct TabToolbar: View {
    let isRefreshing: Bool
    let showsViewModeControls: Bool
    let searchText: Binding<String>?
    let isLoadingSearch: Bool
    let jobDetailViewMode: JobDetailViewMode
    let strings: AppStrings
    let onRefresh: () -> Void
    let onJobDetailViewModeChange: (JobDetailViewMode) -> Void
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: UIConstants.Toolbar.controlSpacing) {
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .symbolEffect(.rotate, options: .repeating, isActive: isRefreshing)
            }
            .buttonStyle(.borderless)
            .help(strings[.refresh])
            .accessibilityLabel(strings[.refresh])
            .accessibilityIdentifier("refresh-button")

            Divider()
                .frame(height: UIConstants.Toolbar.dividerHeight)

            if let searchText {
                searchControls(searchText)
            } else {
                if showsViewModeControls {
                    HStack(spacing: UIConstants.Toolbar.viewModeSpacing) {
                        viewModeButton(
                            .detail,
                            systemImage: "list.bullet.rectangle",
                            label: strings[.detailView]
                        )
                        viewModeButton(
                            .card,
                            systemImage: "rectangle.grid.2x2",
                            label: strings[.cardView]
                        )
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal, UIConstants.Toolbar.horizontalPadding)
        .frame(height: UIConstants.Toolbar.height)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }

    private func searchControls(_ searchText: Binding<String>) -> some View {
        HStack(spacing: UIConstants.Toolbar.searchSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(strings[.searchJobs], text: searchText)
                .textFieldStyle(.roundedBorder)
                .focused($isSearchFocused)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("job-search")
            if isLoadingSearch {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .task {
            await Task.yield()
            isSearchFocused = false
        }
    }

    private func viewModeButton(
        _ mode: JobDetailViewMode,
        systemImage: String,
        label: String
    ) -> some View {
        Button {
            onJobDetailViewModeChange(mode)
        } label: {
            Image(systemName: systemImage)
                .frame(
                    width: UIConstants.Toolbar.viewModeButtonSize,
                    height: UIConstants.Toolbar.viewModeButtonSize
                )
                .foregroundStyle(jobDetailViewMode == mode ? Color.accentColor : .secondary)
                .background {
                    if jobDetailViewMode == mode {
                        RoundedRectangle(cornerRadius: UIConstants.Toolbar.viewModeCornerRadius)
                            .fill(Color.accentColor.opacity(0.14))
                    }
                }
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
        .accessibilityIdentifier("job-\(mode.rawValue)-view-button")
    }
}
