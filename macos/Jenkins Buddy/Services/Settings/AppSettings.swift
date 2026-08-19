import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    private(set) var state: AppSettingsState

    private let storage: any SettingsStorage
    private let storageKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        storage: any SettingsStorage = UserDefaultsSettingsStorage(),
        storageKey: String = "app.settings"
    ) {
        self.storage = storage
        self.storageKey = storageKey
        if let data = storage.data(forKey: storageKey),
           let decoded = try? decoder.decode(AppSettingsState.self, from: data) {
            state = decoded
        } else {
            state = AppSettingsState()
        }
    }

    var resolvedLanguage: AppLanguage {
        state.language
    }

    func update(_ mutation: (inout AppSettingsState) -> Void) {
        var nextState = state
        mutation(&nextState)
        state = nextState
        persist()
    }

    func replace(with newState: AppSettingsState) {
        state = newState
        persist()
    }

    private func persist() {
        guard let data = try? encoder.encode(state) else { return }
        storage.set(data, forKey: storageKey)
    }
}
