#!/bin/bash
set -e

# Configuration
APP_NAME="ToDoshido"
DMG_NAME="ToDoshido"
VERSION="1.0.0"
BACKGROUND_COLOR="#1a1a2e"

# Paths
BUILD_DIR="${HOME}/Library/Developer/Xcode/DerivedData/ToDo-dzjyuqtfzchvzshbamivwfyitfpd/Build/Products/Release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_DIR="${HOME}/Desktop"
TEMP_DIR=$(mktemp -d)
FINAL_DMG="${DMG_DIR}/${DMG_NAME}-${VERSION}.dmg"

echo "📦 Creating DMG for ${APP_NAME}..."

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: App not found at ${APP_PATH}"
    echo "Run: xcodebuild -project ToDo.xcodeproj -scheme ToDoshido -configuration Release build"
    exit 1
fi

# Create temporary directory structure
echo "📂 Setting up temporary directory..."
mkdir -p "${TEMP_DIR}"
cp -R "${APP_PATH}" "${TEMP_DIR}/"

# Create Applications symlink
ln -s /Applications "${TEMP_DIR}/Applications"

# Create temporary DMG
echo "💾 Creating temporary DMG..."
TEMP_DMG="${DMG_DIR}/temp-${DMG_NAME}.dmg"
hdiutil create -volname "${DMG_NAME}" -srcfolder "${TEMP_DIR}" -ov -format UDRW "${TEMP_DMG}"

# Mount the temporary DMG
echo "📂 Mounting DMG..."
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "${TEMP_DMG}" | grep '/Volumes/' | sed 's/.*\/Volumes\//\/Volumes\//')

# Set DMG window properties
echo "🎨 Configuring DMG appearance..."
sleep 2

# Use AppleScript to set the appearance
osascript <<EOF
tell application "Finder"
    tell disk "${DMG_NAME}"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 700, 500}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 128
        set background color of viewOptions to {26, 26, 46}
        set position of item "${APP_NAME}.app" of container window to {150, 200}
        set position of item "Applications" of container window to {450, 200}
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Unmount
echo "📤 Finalizing DMG..."
hdiutil detach "${MOUNT_DIR}" -quiet

# Convert to compressed DMG
echo "🗜️  Compressing DMG..."
rm -f "${FINAL_DMG}"
hdiutil convert "${TEMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${FINAL_DMG}"

# Clean up
echo "🧹 Cleaning up..."
rm -rf "${TEMP_DIR}"

echo "✅ DMG created successfully!"
echo "📍 Location: ${FINAL_DMG}"
echo "📦 Size: $(du -h "${FINAL_DMG}" | cut -f1)"

# Open Finder to show the DMG
open -R "${FINAL_DMG}"
