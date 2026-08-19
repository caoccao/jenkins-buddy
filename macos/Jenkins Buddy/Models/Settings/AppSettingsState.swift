import Foundation

nonisolated struct JenkinsSettings: Codable, Equatable, Sendable {
    var serverURL = ""
    var username = ""
    var refreshInterval: TimeInterval = 30

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        serverURL = try container.decodeIfPresent(String.self, forKey: .serverURL) ?? ""
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        refreshInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .refreshInterval) ?? 30
    }
}

nonisolated struct NotificationSettings: Codable, Equatable, Sendable {
    var isEnabled = false
    var buildStarted = false
    var buildSucceeded = false
    var buildFailed = true
    var playSound = true

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? false
        buildStarted = try container.decodeIfPresent(Bool.self, forKey: .buildStarted) ?? false
        buildSucceeded = try container.decodeIfPresent(Bool.self, forKey: .buildSucceeded) ?? false
        buildFailed = try container.decodeIfPresent(Bool.self, forKey: .buildFailed) ?? true
        playSound = try container.decodeIfPresent(Bool.self, forKey: .playSound) ?? true
    }

    func allows(_ event: BuildEvent.Kind) -> Bool {
        guard isEnabled else { return false }
        return switch event {
        case .started: buildStarted
        case .succeeded: buildSucceeded
        case .failed, .unstable: buildFailed
        }
    }
}

nonisolated struct AppSettingsState: Codable, Equatable, Sendable {
    var language = AppLanguage.english
    var jenkins = JenkinsSettings()
    var notifications = NotificationSettings()

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        language = try container.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .english
        jenkins = try container.decodeIfPresent(JenkinsSettings.self, forKey: .jenkins) ?? JenkinsSettings()
        notifications = try container.decodeIfPresent(NotificationSettings.self, forKey: .notifications) ?? NotificationSettings()
    }
}
