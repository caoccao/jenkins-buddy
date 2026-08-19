import Foundation

nonisolated enum BuildStatus: String, Codable, CaseIterable, Sendable {
    case success
    case failure
    case unstable
    case aborted
    case notBuilt
    case disabled
    case building
    case unknown

    init(jenkinsColor: String?) {
        guard let color = jenkinsColor?.lowercased(), !color.isEmpty else {
            self = .unknown
            return
        }
        if color.hasSuffix("_anime") {
            self = .building
            return
        }
        switch color {
        case "blue", "green": self = .success
        case "red": self = .failure
        case "yellow": self = .unstable
        case "aborted": self = .aborted
        case "notbuilt", "grey", "gray": self = .notBuilt
        case "disabled": self = .disabled
        default: self = .unknown
        }
    }

    init(result: String?, building: Bool) {
        if building {
            self = .building
            return
        }
        switch result?.uppercased() {
        case "SUCCESS": self = .success
        case "FAILURE": self = .failure
        case "UNSTABLE": self = .unstable
        case "ABORTED": self = .aborted
        case "NOT_BUILT": self = .notBuilt
        default: self = .unknown
        }
    }

    var isFailure: Bool {
        self == .failure || self == .unstable
    }
}
