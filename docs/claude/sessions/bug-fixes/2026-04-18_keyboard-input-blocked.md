# Session: Fix Keyboard Input Blocking Issue

**Date:** 2026-04-18  
**Type:** Bug Fix

---

## Session Summary

Fixed critical bug where keyboard and mouse input would stop working in Todoshido and sometimes other apps. Root cause was leaked NSEvent monitors in the HotkeyRecorder component that swallowed keyboard events system-wide.

---

## Problem Description

User reported that:
- Buttons stop responding to clicks (add new item, complete task, etc.)
- Text fields stop accepting input
- Sometimes other apps' buttons stop working while Todoshido is open
- Closing Todoshido restores normal input handling

---

## Root Causes Identified

### 1. NSEvent Monitor Leak in HotkeyRecorder
- **File:** `ToDo/Presentation/Settings/Components/HotkeyRecorder.swift`
- **Issue:** `addLocalMonitorForEvents()` was called multiple times without cleanup
- **Impact:** Event monitor returning `nil` swallowed all keyboard events system-wide
- **Why it happened:** 
  - `updateNSView()` called `startRecording()` on every view update while `isRecording == true`
  - No check to prevent duplicate monitors
  - No cleanup when `isRecording` changed to `false`
  - No timeout failsafe for stuck recording state

### 2. Window Focus Loop in MenuBarView
- **File:** `ToDo/Presentation/MenuBar/MenuBarView.swift`
- **Issue:** Looped through ALL windows calling `makeKeyAndOrderFront()`
- **Impact:** Could cause focus conflicts affecting input handling
- **Why it happened:** Overly broad attempt to bring app to foreground

---

## Changes Made

### HotkeyRecorder.swift

1. **Prevent Duplicate Monitors** (lines 39-52)
   - Added check `if context.coordinator.monitor == nil` before starting recording
   - Added explicit `stopRecording()` when `isRecording == false`

2. **Guard Against Duplicate Starts** (lines 75-79)
   - Added guard statement in `startRecording()` to exit if monitor already exists
   - Added debug logging

3. **Added Timeout Failsafe** (lines 99-107)
   - 30-second timeout task auto-cancels stuck recording state
   - Prevents permanent keyboard blocking

4. **Improved Cleanup** (lines 125-133)
   - Cancel timeout task in `stopRecording()`
   - Added debug logging for monitor lifecycle

5. **Made monitor fileprivate** (line 62)
   - Allows parent view to check monitor existence

### MenuBarView.swift

**Targeted Window Activation** (lines 103-112)
- Changed from looping all windows to finding specific main window
- Uses `windows.first(where:)` with predicate for normal-level, key-capable window
- Only activates the one relevant window

---

## Key Decisions

1. **30-second timeout chosen** - Long enough for normal use, short enough to prevent permanent blocking
2. **Error-level logging for timeout** - Important enough to surface in logs
3. **fileprivate monitor access** - Allows view to check state without exposing to everyone
4. **Target main window only** - More precise than activating all windows

---

## Testing Recommendations

Test these scenarios:
1. Open Settings → Click hotkey field → Press Escape or click away (should not block input)
2. Open Settings → Click hotkey field → Wait 30+ seconds (timeout should cancel)
3. Open Settings → Click hotkey field → Close Settings window (cleanup should happen)
4. Click menu bar item → Click todo (should activate main window without conflicts)
5. Use app normally for 5+ minutes (no gradual input degradation)

---

## Next Steps

- Monitor for any further input handling issues
- Consider adding telemetry for event monitor lifecycle
- Consider shorter timeout (15s) if 30s feels too long

---

## Commands Reference

```bash
# Build
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido build

# Check for NSEvent usage
grep -r "addLocalMonitorForEvents\|addGlobalMonitorForEvents" ToDo/
```
