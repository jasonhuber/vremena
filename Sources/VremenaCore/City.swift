import Foundation

/// A selectable location: a city tied to an IANA time zone, with a country flag.
public struct City: Codable, Identifiable, Hashable, Sendable {
    public var id: String { timeZoneID }
    public let name: String
    public let country: String
    public let flag: String
    public let timeZoneID: String

    public init(name: String, country: String, flag: String, timeZoneID: String) {
        self.name = name
        self.country = country
        self.flag = flag
        self.timeZoneID = timeZoneID
    }

    /// `true` if the named time zone actually exists on this system.
    public var isValidTimeZone: Bool {
        TimeZone(identifier: timeZoneID) != nil
    }

    public var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? .current
    }

    /// Lowercased haystack for search matching.
    public var searchText: String {
        "\(name) \(country) \(timeZoneID)".lowercased()
    }
}
