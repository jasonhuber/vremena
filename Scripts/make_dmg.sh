#!/usr/bin/env bash
# Builds a distributable Vremena.dmg with a drag-to-Applications layout.
# Requires build/Vremena.app (run Scripts/package_app.sh first; this script
# will build it automatically if missing).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${VERSION:-1.0.1}"
APP="$ROOT/build/Vremena.app"
DMG="$ROOT/build/Vremena-$VERSION.dmg"
STAGE="$ROOT/build/dmg-stage"
VOLNAME="Vremena"

if [[ ! -d "$APP" ]]; then
  echo "==> build/Vremena.app missing; building it"
  VERSION="$VERSION" "$ROOT/Scripts/package_app.sh"
fi

echo "==> Staging DMG contents"
rm -rf "$STAGE" "$DMG"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/Vremena.app"
ln -s /Applications "$STAGE/Applications"   # drag target

echo "==> Creating compressed DMG"
hdiutil create \
  -volname "$VOLNAME" \
  -srcfolder "$STAGE" \
  -fs HFS+ \
  -format UDZO \
  -ov \
  "$DMG" >/dev/null

rm -rf "$STAGE"

# --- Sign + notarize ---------------------------------------------------------
# For a Gatekeeper-clean download set BOTH:
#   SIGN_IDENTITY="Developer ID Application: JASON JOHN HUBER (PZB47EEJUG)"
#   NOTARY_PROFILE="vremena-notary"   (from: xcrun notarytool store-credentials)
# package_app.sh must have signed the .app with the same Developer ID first.
if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  echo "==> Signing DMG with Developer ID"
  codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG"
else
  echo "==> Ad-hoc signing DMG (set SIGN_IDENTITY for distribution)"
  codesign --force --sign - "$DMG" >/dev/null 2>&1 || echo "   (codesign skipped)"
fi

if [[ -n "${NOTARY_PROFILE:-}" ]]; then
  echo "==> Submitting to Apple notary (this can take a few minutes)"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  echo "==> Stapling notarization ticket"
  xcrun stapler staple "$DMG"
  xcrun stapler validate "$DMG"
  spctl -a -t open --context context:primary-signature -v "$DMG" || true
fi

SIZE="$(du -h "$DMG" | cut -f1)"
echo "==> Done: $DMG ($SIZE)"
