import SwiftUI
import VremenaCore

/// The management window: choose clocks, reorder them, and set display options.
struct SettingsView: View {
    @ObservedObject var store: ClockStore
    @State private var query: String = ""

    private var availableCities: [City] {
        CityCatalog.search(query).filter { !store.settings.contains($0.timeZoneID) }
    }

    var body: some View {
        HSplitView {
            yourClocks
                .frame(minWidth: 280)
            addCity
                .frame(minWidth: 260)
        }
        .frame(width: 620, height: 460)
    }

    // MARK: - Left: selected clocks + options

    private var yourClocks: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Your Clocks", subtitle: "Drag to reorder. The top clocks fill the menu bar.")

            if store.selectedCities.isEmpty {
                Text("No clocks selected yet — add some from the right.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(14)
                Spacer()
            } else {
                List {
                    ForEach(store.selectedCities) { city in
                        HStack(spacing: 10) {
                            Text(city.flag).font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(city.name).font(.system(size: 13, weight: .medium))
                                Text(city.country).font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                store.remove(city.timeZoneID)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                            }
                            .buttonStyle(.borderless)
                            .help("Remove")
                        }
                        .padding(.vertical, 2)
                    }
                    .onMove { source, destination in
                        store.move(fromOffsets: source, toOffset: destination)
                    }
                }
                .listStyle(.inset)
            }

            Divider()
            optionsPanel
        }
    }

    private var optionsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Stepper(value: menuBarCountBinding, in: 1...max(1, store.selectedCities.count)) {
                HStack {
                    Image(systemName: "menubar.rectangle")
                    Text("Show \(store.settings.effectiveMenuBarCount) in menu bar")
                }
                .font(.system(size: 12))
            }
            .disabled(store.selectedCities.count <= 1)

            Toggle(isOn: boolBinding(\.use24Hour)) {
                Text("24-hour time").font(.system(size: 12))
            }
            Toggle(isOn: boolBinding(\.showSeconds)) {
                Text("Show seconds").font(.system(size: 12))
            }
            Toggle(isOn: launchAtLoginBinding) {
                Text("Launch at login").font(.system(size: 12))
            }
        }
        .toggleStyle(.switch)
        .padding(14)
    }

    // MARK: - Right: catalog

    private var addCity: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Add a City", subtitle: "Search by city, country, or zone.")
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search…", text: $query)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 14)
            .padding(.bottom, 8)

            List {
                ForEach(availableCities, id: \.id) { (city: City) in
                    Button {
                        store.add(city.timeZoneID)
                    } label: {
                        HStack(spacing: 10) {
                            Text(city.flag).font(.system(size: 18))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(city.name).font(.system(size: 13, weight: .medium))
                                Text(city.country).font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill").foregroundStyle(Color.accentColor)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.inset)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
    }

    private var menuBarCountBinding: Binding<Int> {
        Binding(
            get: { store.settings.effectiveMenuBarCount },
            set: { store.setMenuBarCount($0) }
        )
    }

    private func boolBinding(_ keyPath: WritableKeyPath<ClockSettings, Bool>) -> Binding<Bool> {
        Binding(
            get: { store.settings[keyPath: keyPath] },
            set: { store.settings[keyPath: keyPath] = $0 }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { store.settings.launchAtLogin },
            set: { store.applyLaunchAtLogin($0) }
        )
    }
}
