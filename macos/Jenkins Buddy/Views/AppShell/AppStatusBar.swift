import SwiftUI

struct AppStatusBar: View {
    let connectionState: AppViewModel.ConnectionState
    let monitoredJobCount: Int
    let strings: AppStrings

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(isOnline ? Color.green : Color.secondary)
                .frame(width: 7, height: 7)
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider().frame(height: 12)
            Text(strings.formatted(.monitoredJobs, monitoredJobCount))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: AppLayout.statusBarHeight)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    private var isOnline: Bool {
        connectionState == .online
    }

    private var statusText: String {
        switch connectionState {
        case .online: strings[.online]
        case .loading: strings[.loadingJobs]
        case .notConfigured: strings[.configureJenkins]
        case .offline: strings[.offline]
        }
    }
}
