import Foundation

/// A curated catalog of major world cities with country flags and IANA time zones.
public enum CityCatalog {
    public static let all: [City] = [
        // North America
        City(name: "Honolulu", country: "USA", flag: "🇺🇸", timeZoneID: "Pacific/Honolulu"),
        City(name: "Anchorage", country: "USA", flag: "🇺🇸", timeZoneID: "America/Anchorage"),
        City(name: "Los Angeles", country: "USA", flag: "🇺🇸", timeZoneID: "America/Los_Angeles"),
        City(name: "Phoenix", country: "USA", flag: "🇺🇸", timeZoneID: "America/Phoenix"),
        City(name: "Denver", country: "USA", flag: "🇺🇸", timeZoneID: "America/Denver"),
        City(name: "Chicago", country: "USA", flag: "🇺🇸", timeZoneID: "America/Chicago"),
        City(name: "New York", country: "USA", flag: "🇺🇸", timeZoneID: "America/New_York"),
        City(name: "Toronto", country: "Canada", flag: "🇨🇦", timeZoneID: "America/Toronto"),
        City(name: "Vancouver", country: "Canada", flag: "🇨🇦", timeZoneID: "America/Vancouver"),
        City(name: "Mexico City", country: "Mexico", flag: "🇲🇽", timeZoneID: "America/Mexico_City"),

        // South America
        City(name: "Bogotá", country: "Colombia", flag: "🇨🇴", timeZoneID: "America/Bogota"),
        City(name: "Lima", country: "Peru", flag: "🇵🇪", timeZoneID: "America/Lima"),
        City(name: "Santiago", country: "Chile", flag: "🇨🇱", timeZoneID: "America/Santiago"),
        City(name: "Buenos Aires", country: "Argentina", flag: "🇦🇷", timeZoneID: "America/Argentina/Buenos_Aires"),
        City(name: "São Paulo", country: "Brazil", flag: "🇧🇷", timeZoneID: "America/Sao_Paulo"),

        // Europe
        City(name: "London", country: "UK", flag: "🇬🇧", timeZoneID: "Europe/London"),
        City(name: "Dublin", country: "Ireland", flag: "🇮🇪", timeZoneID: "Europe/Dublin"),
        City(name: "Lisbon", country: "Portugal", flag: "🇵🇹", timeZoneID: "Europe/Lisbon"),
        City(name: "Madrid", country: "Spain", flag: "🇪🇸", timeZoneID: "Europe/Madrid"),
        City(name: "Paris", country: "France", flag: "🇫🇷", timeZoneID: "Europe/Paris"),
        City(name: "Amsterdam", country: "Netherlands", flag: "🇳🇱", timeZoneID: "Europe/Amsterdam"),
        City(name: "Brussels", country: "Belgium", flag: "🇧🇪", timeZoneID: "Europe/Brussels"),
        City(name: "Berlin", country: "Germany", flag: "🇩🇪", timeZoneID: "Europe/Berlin"),
        City(name: "Zürich", country: "Switzerland", flag: "🇨🇭", timeZoneID: "Europe/Zurich"),
        City(name: "Rome", country: "Italy", flag: "🇮🇹", timeZoneID: "Europe/Rome"),
        City(name: "Zagreb", country: "Croatia", flag: "🇭🇷", timeZoneID: "Europe/Zagreb"),
        City(name: "Vienna", country: "Austria", flag: "🇦🇹", timeZoneID: "Europe/Vienna"),
        City(name: "Prague", country: "Czechia", flag: "🇨🇿", timeZoneID: "Europe/Prague"),
        City(name: "Stockholm", country: "Sweden", flag: "🇸🇪", timeZoneID: "Europe/Stockholm"),
        City(name: "Oslo", country: "Norway", flag: "🇳🇴", timeZoneID: "Europe/Oslo"),
        City(name: "Copenhagen", country: "Denmark", flag: "🇩🇰", timeZoneID: "Europe/Copenhagen"),
        City(name: "Helsinki", country: "Finland", flag: "🇫🇮", timeZoneID: "Europe/Helsinki"),
        City(name: "Warsaw", country: "Poland", flag: "🇵🇱", timeZoneID: "Europe/Warsaw"),
        City(name: "Athens", country: "Greece", flag: "🇬🇷", timeZoneID: "Europe/Athens"),
        City(name: "Istanbul", country: "Türkiye", flag: "🇹🇷", timeZoneID: "Europe/Istanbul"),
        City(name: "Moscow", country: "Russia", flag: "🇷🇺", timeZoneID: "Europe/Moscow"),

        // Africa
        City(name: "Casablanca", country: "Morocco", flag: "🇲🇦", timeZoneID: "Africa/Casablanca"),
        City(name: "Lagos", country: "Nigeria", flag: "🇳🇬", timeZoneID: "Africa/Lagos"),
        City(name: "Cairo", country: "Egypt", flag: "🇪🇬", timeZoneID: "Africa/Cairo"),
        City(name: "Johannesburg", country: "South Africa", flag: "🇿🇦", timeZoneID: "Africa/Johannesburg"),
        City(name: "Nairobi", country: "Kenya", flag: "🇰🇪", timeZoneID: "Africa/Nairobi"),

        // Middle East
        City(name: "Tel Aviv", country: "Israel", flag: "🇮🇱", timeZoneID: "Asia/Jerusalem"),
        City(name: "Riyadh", country: "Saudi Arabia", flag: "🇸🇦", timeZoneID: "Asia/Riyadh"),
        City(name: "Dubai", country: "UAE", flag: "🇦🇪", timeZoneID: "Asia/Dubai"),
        City(name: "Tehran", country: "Iran", flag: "🇮🇷", timeZoneID: "Asia/Tehran"),

        // Asia
        City(name: "Karachi", country: "Pakistan", flag: "🇵🇰", timeZoneID: "Asia/Karachi"),
        City(name: "Mumbai", country: "India", flag: "🇮🇳", timeZoneID: "Asia/Kolkata"),
        City(name: "Dhaka", country: "Bangladesh", flag: "🇧🇩", timeZoneID: "Asia/Dhaka"),
        City(name: "Bangkok", country: "Thailand", flag: "🇹🇭", timeZoneID: "Asia/Bangkok"),
        City(name: "Jakarta", country: "Indonesia", flag: "🇮🇩", timeZoneID: "Asia/Jakarta"),
        City(name: "Singapore", country: "Singapore", flag: "🇸🇬", timeZoneID: "Asia/Singapore"),
        City(name: "Hong Kong", country: "Hong Kong", flag: "🇭🇰", timeZoneID: "Asia/Hong_Kong"),
        City(name: "Shanghai", country: "China", flag: "🇨🇳", timeZoneID: "Asia/Shanghai"),
        City(name: "Taipei", country: "Taiwan", flag: "🇹🇼", timeZoneID: "Asia/Taipei"),
        City(name: "Seoul", country: "South Korea", flag: "🇰🇷", timeZoneID: "Asia/Seoul"),
        City(name: "Tokyo", country: "Japan", flag: "🇯🇵", timeZoneID: "Asia/Tokyo"),

        // Oceania
        City(name: "Perth", country: "Australia", flag: "🇦🇺", timeZoneID: "Australia/Perth"),
        City(name: "Sydney", country: "Australia", flag: "🇦🇺", timeZoneID: "Australia/Sydney"),
        City(name: "Auckland", country: "New Zealand", flag: "🇳🇿", timeZoneID: "Pacific/Auckland"),

        // Reference
        City(name: "UTC", country: "Coordinated", flag: "🌐", timeZoneID: "UTC"),
    ]

    /// Default selection on first launch: the user's local zone (if catalogued) plus a sensible second.
    public static let defaultSelectionIDs: [String] = ["America/New_York", "Europe/London"]

    public static func city(withID id: String) -> City? {
        all.first { $0.timeZoneID == id }
    }

    /// Case-insensitive search over name, country, and zone identifier.
    public static func search(_ query: String) -> [City] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return all }
        return all.filter { $0.searchText.contains(q) }
    }
}
