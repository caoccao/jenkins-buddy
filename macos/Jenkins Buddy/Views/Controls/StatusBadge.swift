import SwiftUI

struct StatusBadge: View {
    let status: BuildStatus
    let strings: AppStrings

    var body: some View {
        Label(strings.status(status), systemImage: StatusColors.symbol(for: status))
            .font(.callout.weight(.medium))
            .foregroundStyle(StatusColors.color(for: status))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(StatusColors.color(for: status).opacity(0.12), in: Capsule())
    }
}

struct StatusDot: View {
    let status: BuildStatus

    var body: some View {
        Image(systemName: StatusColors.symbol(for: status))
            .foregroundStyle(StatusColors.color(for: status))
            .symbolEffect(.rotate, options: .repeating, isActive: status == .building)
    }
}
