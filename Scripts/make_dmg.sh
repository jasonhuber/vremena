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

echo "==> Ad-hoc signing DMG"
codesign --force --sign - "$DMG" >/dev/null 2>&1 || echo "   (codesign skipped)"

SIZE="$(du -h "$DMG" | cut -f1)"
echo "==> Done: $DMG ($SIZE)"
