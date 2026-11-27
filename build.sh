#!/bin/bash
# Builds Badgertop.app (Apple Silicon + Intel) into ~/Applications and launches it.
#   ./build.sh            build and launch
#   ./build.sh --no-open  build only
#   APP_DIR=dist ./build.sh --no-open   build elsewhere (used by release.sh)
set -e
cd "$(dirname "$0")"
APP="${APP_DIR:-$HOME/Applications}/Badgertop.app"
SRC="main.swift Pixel.swift Lines.swift LinesEN.swift LinesDE.swift LinesES.swift LinesFR.swift Lang.swift UIText.swift Store.swift Settings.swift Life.swift"
TMP="$(mktemp -d)"
[ -z "$APP_DIR" ] && { pkill -x Badgertop 2>/dev/null || true; pkill -x Zviratka 2>/dev/null || true; }
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -swift-version 5 -target arm64-apple-macos13.0 -o "$TMP/arm64" $SRC
swiftc -O -swift-version 5 -target x86_64-apple-macos13.0 -o "$TMP/x86_64" $SRC
lipo -create "$TMP/arm64" "$TMP/x86_64" -output "$APP/Contents/MacOS/Badgertop"
rm -rf "$TMP"
cp Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
codesign --force --sign "${SIGN_ID:--}" ${SIGN_ID:+--options runtime --timestamp} "$APP" >/dev/null 2>&1
[ "$1" = "--no-open" ] || open "$APP"
echo "OK: $APP"
