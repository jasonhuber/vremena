import SwiftUI
import AppKit
import VremenaCore

/// The hover/click panel: every selected clock, live-updating once a second.
struct PopoverView: View {
    @ObservedObject var store: ClockStore

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            clockList
            Divider()
            footer
        }
        .frame(width: 320)
        .frame(minHeight: 200)
    }

    private var header: some View {
        HStack {
            Text("Vremena")
                .font(.headline)
            Spacer()
            Text(Date(), format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var clockList: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = context.date
            let fmt = store.formatter
            ScrollView {
                VStack(spacing: 0) {
                    if store.selectedCities.isEmpty {
                        emptyState
                    } else {
                        ForEach(Array(store.selectedCities.enumerated()), id: \.element.id) { index, city in
                            ClockRow(
                                city: city,
                                time: fmt.timeWithMeridiem(for: city, at: now),
                                date: fmt.dateLabel(for: city, at: now),
                                offset: fmt.relativeOffset(for: city, at: now),
                                isInMenuBar: index < store.settings.effectiveMenuBarCount
                            )
                            if city.id != store.selectedCities.last?.id {
                                Divider().padding(.leading, 14)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No clocks yet")
                .font(.subheadline).bold()
            Text("Add cities to show their time in the menu bar.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
    }

    private var footer: some View {
        HStack {
            Button {
                SettingsWindowController.shared.show(store: store)
            } label: {
                Label("Edit Clocks…", systemImage: "slider.horizontal.3")
            }
            Spacer()
            Button {
                NSApp.terminate(nil)
            } label: {
                Image(systemName: "power")
            }
            .help("Quit Vremena")
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

/// A single clock line: flag, city, live time, date, and offset from local.
struct ClockRow: View {
    let city: City
    let time: String
    let date: String
    let offset: String
    let isInMenuBar: Bool

    var body: some View {
        HStack(spacing: 10) {
            Text(city.flag)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 5) {
                    Text(city.name)
                        .font(.system(size: 13, weight: .medium))
                    if isInMenuBar {
                        Image(systemName: "menubar.rectangle")
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                            .help("Shown in the menu bar")
                    }
                }
                Text(date)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(time)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(offset)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }
}
