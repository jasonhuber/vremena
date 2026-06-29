import AppKit

// Manual entry point so the app runs as a status-bar accessory with no Dock icon.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
