import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?
    let store = ClockStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Only one Vremena may run at a time. A second copy (e.g. one in
        // /Applications and one in Downloads) would add its own menu bar item
        // with its own state, so edits in one wouldn't show in the other.
        if terminateIfAlreadyRunning() { return }

        // Menu bar accessory only — no Dock icon, no main window.
        NSApp.setActivationPolicy(.accessory)
        statusBar = StatusBarController(store: store)
    }

    /// Returns true (and quits this process) if another instance with the same
    /// bundle identifier is already running.
    private func terminateIfAlreadyRunning() -> Bool {
        guard let bundleID = Bundle.main.bundleIdentifier else { return false }
        let me = NSRunningApplication.current
        let others = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleID)
            .filter { $0.processIdentifier != me.processIdentifier && !$0.isTerminated }
        guard let existing = others.first else { return false }
        existing.activate(options: [.activateAllWindows])
        NSApp.terminate(nil)
        return true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        SettingsWindowController.shared.show(store: store)
        return true
    }
}
