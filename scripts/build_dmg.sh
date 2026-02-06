#!/bin/bash
set -e

APP_NAME="Clipboard Manager"
BUILD_DIR="$PWD/build/Release"
DMG_DIR="$PWD/build/dmg"

mkdir -p "$DMG_DIR"

create-dmg \
  --volname "$APP_NAME Installer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 200 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 600 185 \
  "$DMG_DIR/$APP_NAME.dmg" \
  "$BUILD_DIR/$APP_NAME.app"
