import Foundation

extension Notification.Name {
    static let showJenkinsBuddySettings = Notification.Name("showJenkinsBuddySettings")
    static let refreshJenkinsBuddy = Notification.Name("refreshJenkinsBuddy")
    static let jenkinsBuddyConnectionChanged = Notification.Name("jenkinsBuddyConnectionChanged")
    static let openJenkinsBuddyJob = Notification.Name("openJenkinsBuddyJob")
}

nonisolated struct OpenJobEvent: Sendable {
    let jobURL: URL
    let jobName: String
}

enum AppEventBus {
    static func showSettings(center: NotificationCenter = .default) {
        center.post(name: .showJenkinsBuddySettings, object: nil)
    }

    static func refresh(center: NotificationCenter = .default) {
        center.post(name: .refreshJenkinsBuddy, object: nil)
    }

    static func connectionChanged(center: NotificationCenter = .default) {
        center.post(name: .jenkinsBuddyConnectionChanged, object: nil)
    }

    static func openJob(_ event: OpenJobEvent, center: NotificationCenter = .default) {
        center.post(name: .openJenkinsBuddyJob, object: event)
    }
}
