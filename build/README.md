# Build Artifacts

This folder contains distribution packages for Todoshido.

## Creating a DMG

From the project root, run:

```bash
./create-dmg.sh
```

This will:
1. Build the Release version of the app
2. Create a DMG installer in this `build/` folder
3. Configure the DMG with a nice appearance and Applications symlink

## DMG Files

- `ToDoshido-{VERSION}.dmg` - Distribution package for macOS

DMG files are excluded from version control (see `.gitignore`).

## Requirements

- Xcode must have built a Release version of the app
- macOS with `hdiutil` and AppleScript support
