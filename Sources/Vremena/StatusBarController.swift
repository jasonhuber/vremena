import AppKit
import SwiftUI
import Combine
import VremenaCore

/// Owns the menu bar item: renders the first N clocks as the title, ticks every
/// second, and reveals the full list in a popover on hover or click.
final class StatusBarController: NSObject {
    private let store: ClockStore
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var timer: Timer?
    private var trackingArea: NSTrackingArea?
    private var cancellable: AnyCancellable?

    init(store: ClockStore) {
        self.store = store
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        configurePopover()
        configureButton()

        // Re-render immediately whenever settings change.
        cancellable = store.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async { self?.refreshTitle() }
        }

        startTimer()
        refreshTitle()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Setup

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        let root = PopoverView(store: store)
            .environmentObject(store)
        popover.contentViewController = NSHostingController(rootView: root)
        popover.contentSize = NSSize(width: 320, height: 420)
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(handleClick)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.imagePosition = .noImage
    }

    private func startTimer() {
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshTitle()
        }
        // Keep ticking while menus/tracking are active.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    // MARK: - Rendering

    private func refreshTitle() {
        guard let button = statusItem.button else { return }
        let now = Date()
        let title = store.formatter.menuBarTitle(
            for: store.selectedCities,
            count: store.settings.effectiveMenuBarCount,
            at: now
        )
        let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        button.attributedTitle = NSAttributedString(
            string: title,
            attributes: [.font: font]
        )
        installTrackingArea(on: button)
    }

    /// Re-install the hover tracking area sized to the (changing) button bounds.
    private func installTrackingArea(on button: NSStatusBarButton) {
        if let existing = trackingArea {
            button.removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: button.bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self,
            userInfo: nil
        )
        button.addTrackingArea(area)
        trackingArea = area
    }

    // MARK: - Interaction

    @objc private func handleClick() {
        togglePopover()
    }

    /// Delivered by the button's tracking area (we are its owner).
    @objc func mouseEntered(with event: NSEvent) {
        showPopover()
    }

    private func togglePopover() {
        if popover.isShown { popover.performClose(nil) } else { showPopover() }
    }

    private func showPopover() {
        guard !popover.isShown, let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }
}
