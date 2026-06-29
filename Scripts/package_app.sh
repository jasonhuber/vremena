#!/usr/bin/env bash
# Builds Vremena.app — a self-contained menu bar app bundle — from the SwiftPM
# executable. Produces build/Vremena.app. No Xcode project required.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_NAME="Vremena"
BUNDLE_ID="app.vremena.Vremena"
VERSION="${VERSION:-1.0.0}"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "==> Building release binary"
swift build -c release --product "$APP_NAME"
BIN="$(swift build -c release --product "$APP_NAME" --show-bin-path)/$APP_NAME"

echo "==> Assembling bundle at $APP"
rm -rf "$APP"
mkdir -p "$MACOS" "$RESOURCES"
cp "$BIN" "$MACOS/$APP_NAME"

# --- App icon (.icns) -------------------------------------------------------
if [[ -f "$ROOT/Resources/icon_1024.png" ]]; then
  echo "==> Building icon"
  ICONSET="$BUILD_DIR/Vremena.iconset"
  rm -rf "$ICONSET"; mkdir -p "$ICONSET"
  SRC="$ROOT/Resources/icon_1024.png"
  for sz in 16 32 64 128 256 512 1024; do
    sips -z $sz $sz "$SRC" --out "$ICONSET/icon_${sz}x${sz}.png" >/dev/null
  done
  # Retina (@2x) variants
  cp "$ICONSET/icon_32x32.png"   "$ICONSET/icon_16x16@2x.png"
  cp "$ICONSET/icon_64x64.png"   "$ICONSET/icon_32x32@2x.png"
  cp "$ICONSET/icon_256x256.png" "$ICONSET/icon_128x128@2x.png"
  cp "$ICONSET/icon_512x512.png" "$ICONSET/icon_256x256@2x.png"
  cp "$ICONSET/icon_1024x1024.png" "$ICONSET/icon_512x512@2x.png"
  rm -f "$ICONSET/icon_64x64.png" "$ICONSET/icon_1024x1024.png"
  iconutil -c icns "$ICONSET" -o "$RESOURCES/AppIcon.icns"
fi

# --- Info.plist -------------------------------------------------------------
cat > "$CONTENTS/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>     <string>Vremena</string>
    <key>CFBundleIdentifier</key>      <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>         <string>$VERSION</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleExecutable</key>      <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>  <string>13.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSHighResolutionCapable</key> <true/>
    <key>NSHumanReadableCopyright</key><string>Vremena — world clocks for your menu bar.</string>
</dict>
</plist>
PLIST

# --- Code signature ----------------------------------------------------------
# Set SIGN_IDENTITY to a Developer ID for a distributable, notarizable build:
#   SIGN_IDENTITY="Developer ID Application: JASON JOHN HUBER (PZB47EEJUG)"
# Otherwise the app is ad-hoc signed (runs locally, but Gatekeeper blocks others).
if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  echo "==> Signing with Developer ID (hardened runtime)"
  # Hardened runtime + secure timestamp are required for notarization.
  codesign --force --deep --options runtime --timestamp \
    --sign "$SIGN_IDENTITY" "$APP"
  codesign --verify --deep --strict --verbose=2 "$APP"
else
  echo "==> Ad-hoc signing (set SIGN_IDENTITY for a distributable build)"
  codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || \
    echo "   (codesign skipped — bundle still runs locally)"
fi

echo "==> Done: $APP"
echo "    Run it with:  open \"$APP\""
