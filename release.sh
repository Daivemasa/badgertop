#!/bin/bash
# Builds dist/Badgertop-<version>.zip and .dmg for release.
# Without an Apple Developer account the app is ad-hoc signed (first launch: right-click → Open).
# With an account:  SIGN_ID="Developer ID Application: Name (TEAMID)" NOTARY_PROFILE=profile ./release.sh
set -e
cd "$(dirname "$0")"
VER=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" Info.plist)
rm -rf dist && mkdir dist
APP_DIR="$PWD/dist" ./build.sh --no-open
ZIP="dist/Badgertop-$VER.zip"
ditto -c -k --keepParent dist/Badgertop.app "$ZIP"
if [ -n "$NOTARY_PROFILE" ] && [ -n "$SIGN_ID" ]; then
  xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple dist/Badgertop.app
  rm "$ZIP" && ditto -c -k --keepParent dist/Badgertop.app "$ZIP"
fi
# DMG: install window with instructions in the background (needs `pip3 install dmgbuild`),
# otherwise a plain DMG with the app, an Applications shortcut and the text guide.
DMG="dist/Badgertop-$VER.dmg"
DMGBUILD="${DMGBUILD:-$(command -v dmgbuild || true)}"
if [ -n "$DMGBUILD" ]; then
  "$DMGBUILD" -s tools/dmg_settings.py -D app=dist/Badgertop.app -D bg=Resources/dmg-bg.tiff -D readme=docs/FIRST-LAUNCH.txt "Badgertop" "$DMG" >/dev/null
else
  STAGE="$(mktemp -d)/Badgertop"
  mkdir -p "$STAGE"
  cp -R dist/Badgertop.app "$STAGE/"
  ln -s /Applications "$STAGE/Applications"
  cp "docs/FIRST-LAUNCH.txt" "$STAGE/READ ME – first launch.txt"
  hdiutil create -volname "Badgertop" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
  rm -rf "$(dirname "$STAGE")"
fi
shasum -a 256 "$ZIP" "$DMG"
echo "Done: $ZIP and $DMG"
