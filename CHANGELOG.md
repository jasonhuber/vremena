# Changelog

All notable changes to Vremena are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] — 2026-06-29

### Added
- Menu bar app showing multiple world clocks (first two by default, configurable count).
- Hover or click the menu bar item to reveal all selected clocks with city, live time, date, and offset from local.
- Country flag for every location.
- City picker with 60+ cities searchable by name, country, or IANA zone; drag to reorder.
- Display options: 12-/24-hour, optional seconds.
- Launch at login via `SMAppService`.
- Persistence to `UserDefaults` (JSON).
- `Scripts/package_app.sh` to build a self-contained `Vremena.app` (icon + Info.plist + ad-hoc signature) from SwiftPM.
- App icon generator (`Scripts/make_icon.swift`).
- Landing page for vremena.app (`site/`) with GitHub Pages deploy workflow.
- 25 unit tests over the `VremenaCore` logic library.
