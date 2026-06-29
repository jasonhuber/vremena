import Foundation

/// Persisted user choices. Pure value type so it can be unit-tested and
/// round-tripped through JSON without touching AppKit or UserDefaults.
public struct ClockSettings: Codable, Equatable, Sendable {
    /// Ordered time zone identifiers the user has selected.
    public var selectedIDs: [String]
    /// How many clocks to render in the menu bar (the rest appear on hover/click).
    public var menuBarCount: Int
    public var use24Hour: Bool
    public var showSeconds: Bool
    public var launchAtLogin: Bool

    public init(
        selectedIDs: [String] = CityCatalog.defaultSelectionIDs,
        menuBarCount: Int = 2,
        use24Hour: Bool = false,
        showSeconds: Bool = false,
        launchAtLogin: Bool = false
    ) {
        self.selectedIDs = selectedIDs
        self.menuBarCount = menuBarCount
        self.use24Hour = use24Hour
        self.showSeconds = showSeconds
        self.launchAtLogin = launchAtLogin
    }

    /// Resolve selected identifiers to catalog cities, skipping any that no
    /// longer exist in the catalog or on this system.
    public var selectedCities: [City] {
        selectedIDs.compactMap { CityCatalog.city(withID: $0) }.filter { $0.isValidTimeZone }
    }

    /// menuBarCount clamped to something sane given the current selection.
    public var effectiveMenuBarCount: Int {
        let upper = max(1, selectedCities.count)
        return min(max(1, menuBarCount), upper)
    }

    public func contains(_ id: String) -> Bool {
        selectedIDs.contains(id)
    }

    // MARK: - Mutations (return-by-value friendly, but mutate in place)

    public mutating func add(_ id: String) {
        guard CityCatalog.city(withID: id) != nil, !selectedIDs.contains(id) else { return }
        selectedIDs.append(id)
    }

    public mutating func remove(_ id: String) {
        selectedIDs.removeAll { $0 == id }
        clampCount()
    }

    public mutating func toggle(_ id: String) {
        if selectedIDs.contains(id) { remove(id) } else { add(id) }
    }

    /// Reorder selected IDs. Mirrors SwiftUI's `move(fromOffsets:toOffset:)`
    /// semantics so List drag-to-reorder maps straight through.
    public mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        let moving = source.sorted().map { selectedIDs[$0] }
        // Number of removed items before the insertion point shifts it left.
        let adjustedDestination = destination - source.filter { $0 < destination }.count
        for index in source.sorted(by: >) {
            selectedIDs.remove(at: index)
        }
        selectedIDs.insert(contentsOf: moving, at: max(0, min(adjustedDestination, selectedIDs.count)))
    }

    public mutating func setMenuBarCount(_ n: Int) {
        menuBarCount = n
        clampCount()
    }

    private mutating func clampCount() {
        let upper = max(1, selectedIDs.count)
        menuBarCount = min(max(1, menuBarCount), upper)
    }

    // MARK: - Persistence

    public func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }

    public static func decoded(from data: Data) -> ClockSettings? {
        try? JSONDecoder().decode(ClockSettings.self, from: data)
    }
}
