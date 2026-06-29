import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?
    let store = ClockStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu bar accessory only — no Dock icon, no main window.
        NSApp.setActivationPolicy(.accessory)
        statusBar = StatusBarController(store: store)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindowController.shared.show(store: store)
        return true
    }
}
