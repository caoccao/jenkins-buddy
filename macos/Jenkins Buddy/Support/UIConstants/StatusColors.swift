import SwiftUI

enum StatusColors {
    static func color(for status: BuildStatus) -> Color {
        switch status {
        case .success: .green
        case .failure: .red
        case .unstable: .yellow
        case .aborted, .notBuilt, .disabled, .unknown: .secondary
        case .building: .blue
        }
    }

    static func symbol(for status: BuildStatus) -> String {
        switch status {
        case .success: "checkmark.circle.fill"
        case .failure: "xmark.octagon.fill"
        case .unstable: "exclamationmark.triangle.fill"
        case .aborted: "stop.circle.fill"
        case .notBuilt: "minus.circle"
        case .disabled: "pause.circle"
        case .building: "play.fill"
        case .unknown: "questionmark.circle.fill"
        }
    }
}
