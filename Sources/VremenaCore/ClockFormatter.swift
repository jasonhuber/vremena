import Foundation

/// Formats times for a given city. Pure and deterministic — no global state.
public struct ClockFormatter: Sendable {
    public var use24Hour: Bool
    public var showSeconds: Bool

    public init(use24Hour: Bool = false, showSeconds: Bool = false) {
        self.use24Hour = use24Hour
        self.showSeconds = showSeconds
    }

    private func timeFormat() -> String {
        if use24Hour {
            return showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            return showSeconds ? "h:mm:ss" : "h:mm"
        }
    }

    private func formatter(for timeZone: TimeZone, format: String) -> DateFormatter {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = timeZone
        df.dateFormat = format
        return df
    }

    /// Clock face only, e.g. "9:41" or "18:41". 12-hour times include no AM/PM
    /// to stay compact in the menu bar; use `timeWithMeridiem` where it matters.
    public func time(for city: City, at date: Date) -> String {
        formatter(for: city.timeZone, format: timeFormat()).string(from: date)
    }

    /// Clock face with AM/PM when in 12-hour mode, e.g. "9:41 AM".
    public func timeWithMeridiem(for city: City, at date: Date) -> String {
        let fmt = use24Hour ? timeFormat() : timeFormat() + " a"
        return formatter(for: city.timeZone, format: fmt).string(from: date)
    }

    /// A short day/date label, e.g. "Mon, Jun 29".
    public func dateLabel(for city: City, at date: Date) -> String {
        formatter(for: city.timeZone, format: "EEE, MMM d").string(from: date)
    }

    /// Offset from the user's local zone in hours, e.g. "+3h", "-7h", "same".
    public func relativeOffset(for city: City, at date: Date) -> String {
        let local = TimeZone.current.secondsFromGMT(for: date)
        let there = city.timeZone.secondsFromGMT(for: date)
        let deltaHours = Double(there - local) / 3600.0
        if abs(deltaHours) < 0.01 { return "same" }
        let sign = deltaHours > 0 ? "+" : "−"
        // Preserve half-hour / 45-min offsets.
        if deltaHours == deltaHours.rounded() {
            return "\(sign)\(Int(abs(deltaHours)))h"
        }
        return String(format: "%@%.1fh", sign, abs(deltaHours))
    }

    /// The single-entry menu bar token, e.g. "🇬🇧 18:41".
    public func menuBarToken(for city: City, at date: Date) -> String {
        "\(city.flag) \(time(for: city, at: date))"
    }

    /// The full menu bar title for the first `count` cities, joined with spacing.
    /// Returns a default placeholder when nothing is selected.
    public func menuBarTitle(for cities: [City], count: Int, at date: Date) -> String {
        let shown = Array(cities.prefix(max(0, count)))
        guard !shown.isEmpty else { return "🕔 Vremena" }
        return shown.map { menuBarToken(for: $0, at: date) }.joined(separator: "  ")
    }
}
