import SwiftUI

struct JobsTreeView: View {
    let jobs: [JenkinsJob]
    let expandContainers: Bool
    let strings: AppStrings
    let onOpen: (JenkinsJob) -> Void
    let onExpand: (JenkinsJob) -> Void

    var body: some View {
        List {
            ForEach(jobs) { job in
                JobTreeNode(
                    job: job,
                    expandContainers: expandContainers,
                    strings: strings,
                    onOpen: onOpen,
                    onExpand: onExpand
                )
            }
        }
        .listStyle(.sidebar)
        .accessibilityIdentifier("jobs-tree")
    }
}

private struct JobTreeNode: View {
    let job: JenkinsJob
    let expandContainers: Bool
    let strings: AppStrings
    let onOpen: (JenkinsJob) -> Void
    let onExpand: (JenkinsJob) -> Void
    @State private var isExpanded = false

    var body: some View {
        if !job.isContainer {
            JobRow(job: job, strings: strings) { onOpen(job) }
        } else {
            DisclosureGroup(isExpanded: expansionBinding) {
                ForEach(job.children) { child in
                    JobTreeNode(
                        job: child,
                        expandContainers: expandContainers,
                        strings: strings,
                        onOpen: onOpen,
                        onExpand: onExpand
                    )
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(.secondary)
                    Text(job.displayName)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded {
                        expansionBinding.wrappedValue.toggle()
                    }
                )
            }
            .onAppear { expandForSearchIfNeeded() }
            .onChange(of: expandContainers) { _, _ in expandForSearchIfNeeded() }
        }
    }

    private func expandForSearchIfNeeded() {
        if expandContainers {
            isExpanded = true
        }
    }

    private var expansionBinding: Binding<Bool> {
        Binding(
            get: { isExpanded },
            set: { expanded in
                isExpanded = expanded
                if expanded && job.children.isEmpty { onExpand(job) }
            }
        )
    }
}
