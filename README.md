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

### Signed, notarized release (no Gatekeeper warning)

The default build is ad-hoc signed — fine locally, but other Macs show
"Apple cannot verify the developer." For a distributable build, sign with a
**Developer ID Application** certificate and notarize with Apple. One-time setup:

```bash
# 1. Create a "Developer ID Application" cert in Xcode → Settings → Accounts
#    → Manage Certificates → +  (requires the paid Apple Developer Program).
# 2. Store notarization credentials once (app-specific password from appleid.apple.com):
xcrun notarytool store-credentials "vremena-notary" \
  --apple-id "<your-apple-id>" --team-id 4PP234HMPG --password "<app-specific-password>"
```

Then build a notarized DMG:

```bash
export SIGN_IDENTITY="Developer ID Application: Sustav LC (4PP234HMPG)"
export NOTARY_PROFILE="vremena-notary"
VERSION=1.0.1 ./Scripts/package_app.sh   # signs the .app (hardened runtime)
VERSION=1.0.1 ./Scripts/make_dmg.sh      # signs + notarizes + staples the DMG
```

Without these env vars both scripts fall back to ad-hoc signing.

## Architecture

| Target | Role |
| --- | --- |
| `VremenaCore` | Pure logic & models — `City`, `CityCatalog`, `ClockSettings`, `ClockFormatter`. No AppKit. Fully unit-tested. |
| `Vremena` | The menu bar app — `StatusBarController` (NSStatusItem + hover popover), SwiftUI `PopoverView` / `SettingsView`, `ClockStore` (UserDefaults persistence). |
| `VremenaTests` | 25 tests covering the catalog, settings mutations, JSON round-trip, and formatting. |

Settings persist to `UserDefaults` under the key `VremenaSettings` as JSON.

## Website

The landing page lives in [`site/`](site/).

**Primary:** hosted on Hostinger at **https://vremena.app** (Cloudflare in front),
deployed with:

```bash
./Scripts/deploy_site.sh   # reads Hostinger creds from project-root .env (gitignored)
```

This rsyncs `site/` to `~/domains/vremena.app/public_html`, matching the other
Sustav apps. The `.env` mirrors the `HOSTINGER_SSH_*` keys used elsewhere plus
`DEPLOY_PATH`.

> **One-time SSL step:** a new Hostinger domain has no origin TLS cert until it's
> issued, so Cloudflare (Full/strict) returns **525** until then. Install the free
> SSL for `vremena.app` in hPanel (Websites → vremena.app → Security → SSL), or
> temporarily set Cloudflare SSL to *Flexible*. The existing siblings all have
> Let's Encrypt origin certs.

**Mirror:** also auto-deploys to GitHub Pages
(`.github/workflows/pages.yml`) at https://jasonhuber.github.io/vremena/.

## License

MIT — see [LICENSE](LICENSE).
