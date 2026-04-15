# Building ToDoshido

## Quick Build Commands

### Build for Development
```bash
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido -destination 'platform=macOS' build
```

### Build Release Version
```bash
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido -configuration Release -destination 'platform=macOS' clean build
```

### Create DMG for Distribution
```bash
./create-dmg.sh
```

The DMG will be created on your Desktop as `ToDoshido-1.0.0.dmg`

## What's in the DMG

- **ToDoshido.app** - The application bundle
- **Applications symlink** - Drag ToDoshido.app to Applications to install
- Custom icon view with proper spacing
- Compressed format for smaller download size

## Manual DMG Creation (without script)

If you prefer to create a simple DMG manually:

```bash
# Build release version first
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido -configuration Release build

# Create DMG
hdiutil create -volname "ToDoshido" \
  -srcfolder ~/Library/Developer/Xcode/DerivedData/ToDo-*/Build/Products/Release/ToDoshido.app \
  -ov -format UDZO \
  ~/Desktop/ToDoshido.dmg
```

## Build Locations

- **Debug builds**: `~/Library/Developer/Xcode/DerivedData/ToDo-*/Build/Products/Debug/`
- **Release builds**: `~/Library/Developer/Xcode/DerivedData/ToDo-*/Build/Products/Release/`

## App Bundle Details

- **App Name**: ToDoshido
- **Bundle ID**: com.syh.ToDoshido
- **Version**: 1.0.0
- **Platform**: macOS 13.0+
- **Architecture**: Universal (Apple Silicon + Intel)

## Distribution Checklist

Before distributing:
- [ ] Test on clean macOS installation
- [ ] Verify app launches without crashes
- [ ] Check all features work (hotkeys, clipboard capture, persistence)
- [ ] Test Settings panel
- [ ] Verify app icon appears correctly
- [ ] Test menu bar functionality
- [ ] Ensure no debug logs in release build

## Code Signing (Optional)

To sign the app for distribution outside the App Store:

```bash
codesign --force --deep --sign "Developer ID Application: Your Name" \
  ~/Library/Developer/Xcode/DerivedData/ToDo-*/Build/Products/Release/ToDoshido.app
```

To notarize (requires Apple Developer account):

```bash
# Create a ZIP for notarization
ditto -c -k --keepParent ToDoshido.app ToDoshido.zip

# Submit for notarization
xcrun notarytool submit ToDoshido.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --wait

# Staple the notarization ticket
xcrun stapler staple ToDoshido.app
```

## Troubleshooting

### "App is damaged" warning
This happens when the app isn't signed. Users can bypass with:
```bash
xattr -cr /Applications/ToDoshido.app
```

### Build fails
- Clean build folder: `Cmd+Shift+K` in Xcode
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/ToDo-*`
- Rebuild

### DMG script fails
- Ensure you have built the Release version first
- Check disk space on Desktop
- Verify Xcode DerivedData path matches

## Version Updates

To update version number:
1. Edit `create-dmg.sh` and change `VERSION="1.0.0"`
2. Update version in Xcode project settings
3. Rebuild and create new DMG
