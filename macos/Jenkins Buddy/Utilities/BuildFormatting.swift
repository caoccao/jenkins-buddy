import Foundation

enum BuildFormatting {
    static func duration(milliseconds: TimeInterval, locale: Locale = .current) -> String {
        let totalSeconds = max(0, Int(milliseconds / 1_000))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        formatter.zeroFormattingBehavior = .pad
        if hours > 0 {
            formatter.allowedUnits = [.hour, .minute]
        } else if minutes > 0 {
            formatter.allowedUnits = [.minute, .second]
        } else {
            formatter.allowedUnits = [.second]
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        formatter.calendar = calendar
        return formatter.string(from: TimeInterval(totalSeconds)) ?? "\(totalSeconds)"
    }

    static func date(_ date: Date, locale: Locale = .current) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened, locale: locale)
        )
    }
}
