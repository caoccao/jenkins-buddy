import AppKit
import UserNotifications

nonisolated enum NotificationResponseRoute {
    static func event(from userInfo: [AnyHashable: Any]) -> OpenJobEvent? {
        guard let urlValue = userInfo["jobURL"] as? String,
              let jobURL = URL(string: urlValue),
              let jobName = userInfo["jobName"] as? String else {
            return nil
        }
        return OpenJobEvent(jobURL: jobURL, jobName: jobName)
    }
}

nonisolated enum ForegroundNotificationPresentation {
    static var options: UNNotificationPresentationOptions { [.banner, .sound] }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(ForegroundNotificationPresentation.options)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let event = NotificationResponseRoute.event(from: userInfo) {
            completionHandler()
            Task { @MainActor in
                AppEventBus.openJob(event)
                NSApp.activate(ignoringOtherApps: true)
            }
        } else {
            completionHandler()
        }
    }
}
