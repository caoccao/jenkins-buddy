import SwiftUI

@MainActor
enum SettingsWindowRoute {
    static let sceneID = "settings"

    static func open(using action: OpenWindowAction) {
        action(id: sceneID)
    }
}
