import SwiftUI

struct TabsBar: View {
    let tabs: [AppTab]
    let selectedTabID: UUID
    let statuses: [URL: BuildStatus]
    let strings: AppStrings
    let onSelect: (UUID) -> Void
    let onClose: (UUID) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    tabButton(tab)
                }
                Spacer(minLength: 0)
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: UIConstants.Tabs.height)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
        .accessibilityIdentifier("tabs-bar")
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = tab.id == selectedTabID
        return HStack(spacing: 7) {
            if tab.kind == .jobs {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            } else {
                StatusDot(status: tab.jobURL.flatMap { statuses[$0] } ?? .unknown)
            }
            Text(tab.kind == .jobs ? strings[.jobs] : tab.title)
                .lineLimit(1)
                .fontWeight(isSelected ? .semibold : .regular)
            Spacer(minLength: 4)
            if tab.kind == .job {
                Button {
                    onClose(tab.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.weight(.semibold))
                }
                .buttonStyle(.plain)
                .help(strings[.closeTab])
                .accessibilityLabel(strings[.closeTab])
            }
        }
        .padding(.horizontal, 10)
        .frame(minWidth: UIConstants.Tabs.minimumWidth, maxWidth: UIConstants.Tabs.maximumWidth)
        .frame(height: UIConstants.Tabs.height)
        .contentShape(Rectangle())
        .background {
            if isSelected {
                Color.accentColor.opacity(UIConstants.Tabs.selectedBackgroundOpacity)
            }
        }
        .overlay(alignment: .bottom) {
            if isSelected {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(height: UIConstants.Tabs.selectionIndicatorHeight)
            }
        }
        .overlay(alignment: .trailing) { Divider() }
        .onTapGesture { onSelect(tab.id) }
        .accessibilityIdentifier("tab-\(tab.id.uuidString)")
    }
}
