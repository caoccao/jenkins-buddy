import SwiftUI

struct JobRow: View {
    let job: JenkinsJob
    let strings: AppStrings
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                StatusDot(status: job.status)
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.displayName)
                        .foregroundStyle(.primary)
                    if job.displayFullName != job.displayName {
                        Text(job.displayFullName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(strings.status(job.status))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("job-\(job.fullName)")
    }
}
