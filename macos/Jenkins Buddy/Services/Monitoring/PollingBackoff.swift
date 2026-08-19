import Foundation

nonisolated struct PollingBackoff: Equatable, Sendable {
    let baseInterval: TimeInterval
    let maximumInterval: TimeInterval

    init(baseInterval: TimeInterval, maximumInterval: TimeInterval = 300) {
        self.baseInterval = max(1, baseInterval)
        self.maximumInterval = max(self.baseInterval, maximumInterval)
    }

    func delay(afterConsecutiveFailures failures: Int) -> TimeInterval {
        guard failures > 0 else { return baseInterval }
        let exponent = min(failures, 10)
        return min(baseInterval * pow(2, Double(exponent)), maximumInterval)
    }
}
