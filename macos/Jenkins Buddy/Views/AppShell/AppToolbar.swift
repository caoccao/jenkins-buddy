import AppKit
import SwiftUI

struct AppToolbar: View {
    let isRefreshing: Bool
    let jobURL: URL?
    let jobDetailViewMode: JobDetailViewMode
    let strings: AppStrings
    let onRefresh: () -> Void
    let onJobDetailViewModeChange: (JobDetailViewMode) -> Void
    let onSettings: () -> Void

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

            Spacer()

            if let jobURL {
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

                Button {
                    NSWorkspace.shared.open(jobURL)
                } label: {
                    Image(systemName: "safari")
                }
                .buttonStyle(.borderless)
                .help(strings[.openInJenkins])
                .accessibilityLabel(strings[.openInJenkins])
                .accessibilityIdentifier("open-in-jenkins-button")
            }

            Button(action: onSettings) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help(strings[.settings])
            .accessibilityLabel(strings[.settings])
            .accessibilityIdentifier("settings-button")
        }
        .padding(.horizontal, UIConstants.Toolbar.horizontalPadding)
        .frame(height: UIConstants.Toolbar.height)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(alignment: .bottom) { Divider() }
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
