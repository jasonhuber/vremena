# Vremena

World clocks in your macOS menu bar. Pick the cities you care about, see two at a
glance, hover for the rest — each with its country flag. No Dock icon, no window
to keep open.

*Vremena* is Croatian for "times."

![Vremena](site/icon.png)

## Features

- **Multiple clocks in the menu bar** — shows the first two by default; configurable.
- **Hover (or click) to see them all** — full list with city, live time, date, and offset from your local zone.
- **Country flags** for every location.
- **60+ cities** searchable by name, country, or IANA zone. Drag to reorder.
- **12- or 24-hour**, optional seconds.
- **Launch at login** (macOS 13+ `SMAppService`).
- Runs as a menu bar accessory — no Dock icon, no main window.

## Requirements

- macOS 13 (Ventura) or later
- Apple Silicon or Intel

## Install

Download the latest `Vremena.app` from
[Releases](https://github.com/jasonhuber/vremena/releases/latest), move it to
`/Applications`, and open it. Because it's ad-hoc signed (not notarized), the
first launch may need right-click → **Open**.

The clock(s) appear in the menu bar immediately. Click the item, then **Edit
Clocks…** to choose your cities.

## Build from source

The app is a Swift Package — no Xcode project required.

```bash
# Run tests
swift test

# Build a debug binary
swift build

# Produce build/Vremena.app (release, with icon + Info.plist)
./Scripts/package_app.sh
open build/Vremena.app
```

`Scripts/make_icon.swift` regenerates `Resources/icon_1024.png` if you want to
tweak the icon.

## Architecture

| Target | Role |
| --- | --- |
| `VremenaCore` | Pure logic & models — `City`, `CityCatalog`, `ClockSettings`, `ClockFormatter`. No AppKit. Fully unit-tested. |
| `Vremena` | The menu bar app — `StatusBarController` (NSStatusItem + hover popover), SwiftUI `PopoverView` / `SettingsView`, `ClockStore` (UserDefaults persistence). |
| `VremenaTests` | 25 tests covering the catalog, settings mutations, JSON round-trip, and formatting. |

Settings persist to `UserDefaults` under the key `VremenaSettings` as JSON.

## Website

The landing page for [vremena.app](https://vremena.app) lives in [`site/`](site/)
and deploys via GitHub Pages (see `.github/workflows/pages.yml`). The `CNAME`
file points the Pages site at the custom domain.

## License

MIT — see [LICENSE](LICENSE).
