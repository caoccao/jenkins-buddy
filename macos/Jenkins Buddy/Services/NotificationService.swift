import CryptoKit
import Foundation
import UserNotifications

protocol NotificationDelivering: Sendable {
    func requestAuthorization() async throws -> Bool
    func deliver(_ event: BuildEvent, title: String, body: String, playSound: Bool) async throws
}

nonisolated enum NotificationIdentity {
    static func identifier(for event: BuildEvent) -> String {
        hash("\(event.jobURL.absoluteString)|\(event.buildNumber ?? -1)|\(event.kind.rawValue)")
    }

    static func threadIdentifier(for jobURL: URL) -> String {
        hash(jobURL.absoluteString)
    }

    private static func hash(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

enum NotificationPayload {
    static func content(
        for event: BuildEvent,
        title: String,
        body: String,
        playSound: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = playSound ? .default : nil
        content.threadIdentifier = NotificationIdentity.threadIdentifier(for: event.jobURL)
        var userInfo: [String: Any] = [
            "event": event.kind.rawValue,
            "jobName": event.jobName,
            "jobURL": event.jobURL.absoluteString
        ]
        if let buildNumber = event.buildNumber {
            userInfo["buildNumber"] = buildNumber
        }
        content.userInfo = userInfo
        return content
    }
}

final class UserNotificationService: NotificationDelivering, @unchecked Sendable {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func deliver(_ event: BuildEvent, title: String, body: String, playSound: Bool) async throws {
        let content = NotificationPayload.content(
            for: event,
            title: title,
            body: body,
            playSound: playSound
        )
        let request = UNNotificationRequest(
            identifier: NotificationIdentity.identifier(for: event),
            content: content,
            trigger: nil
        )
        try await center.add(request)
    }
}

actor MemoryNotificationService: NotificationDelivering {
    struct Delivery: Equatable, Sendable {
        let event: BuildEvent
        let title: String
        let body: String
        let playSound: Bool
    }

    private(set) var deliveries: [Delivery] = []
    var authorizationResult = true

    func requestAuthorization() -> Bool { authorizationResult }

    func deliver(_ event: BuildEvent, title: String, body: String, playSound: Bool) {
        deliveries.append(Delivery(event: event, title: title, body: body, playSound: playSound))
    }

    func recordedDeliveries() -> [Delivery] { deliveries }
}
