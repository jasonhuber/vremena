import Foundation
import Combine
import ServiceManagement
import VremenaCore

/// Observable wrapper around `ClockSettings`, persisted to UserDefaults.
/// The single source of truth shared by the menu bar and the settings window.
final class ClockStore: ObservableObject {
    private static let defaultsKey = "VremenaSettings"

    @Published var settings: ClockSettings {
        didSet { persist() }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.defaultsKey),
           let loaded = ClockSettings.decoded(from: data) {
            self.settings = loaded
        } else {
            self.settings = ClockSettings()
        }
    }

    private func persist() {
        if let data = settings.encoded() {
            defaults.set(data, forKey: Self.defaultsKey)
        }
    }

    // MARK: - Convenience passthroughs

    var selectedCities: [City] { settings.selectedCities }

    var formatter: ClockFormatter {
        ClockFormatter(use24Hour: settings.use24Hour, showSeconds: settings.showSeconds)
    }

    func toggle(_ id: String) { settings.toggle(id) }
    func add(_ id: String) { settings.add(id) }
    func remove(_ id: String) { settings.remove(id) }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        settings.move(fromOffsets: source, toOffset: destination)
    }

    func setMenuBarCount(_ n: Int) { settings.setMenuBarCount(n) }

    // MARK: - Launch at login (macOS 13+)

    func applyLaunchAtLogin(_ enabled: Bool) {
        settings.launchAtLogin = enabled
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
        } catch {
            NSLog("Vremena: launch-at-login change failed: \(error.localizedDescription)")
        }
    }
}
