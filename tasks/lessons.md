# Lessons Learned

Track corrections and patterns to prevent repeating mistakes.

---

## How to Use This File

After ANY correction from the user:
1. Add an entry below with the mistake and the correct approach
2. Include context about when this applies
3. Review this file at the start of each session

---

## Lessons

### 2026-04-15: Initial Setup

**Pattern:** When setting up Claude documentation, create modular guide files instead of embedding everything in CLAUDE.md.

**Why:** Keeps the main instruction file small and only loads relevant guides when needed.

**How to apply:** Create separate files in `docs/claude/guides/` for each topic and use keyword triggers in CLAUDE.md.

### 2026-04-18: NSEvent Monitor Leaks Can Block System-Wide Input

**Pattern:** When using `NSEvent.addLocalMonitorForEvents()`, prevent duplicate monitors and ensure cleanup happens in all cases (view updates, dismissals, timeouts).

**Why:** A leaked event monitor that returns `nil` swallows keyboard events system-wide. If `isRecording` state gets stuck or monitors aren't removed, it blocks all keyboard input in the app and sometimes other apps.

**How to apply:** 
- Check if monitor exists before creating a new one in `updateNSView()`
- Add explicit cleanup when state changes to `false`
- Add timeout failsafe (30s) to auto-cancel stuck recording states
- Log monitor lifecycle events for debugging
- Always cancel async tasks in cleanup (`timeoutTask?.cancel()`)

**Related:** [HotkeyRecorder.swift](ToDo/Presentation/Settings/Components/HotkeyRecorder.swift)

---

### 2026-04-18: Avoid Window Focus Loops

**Pattern:** When activating windows from menu bar or background, target specific windows instead of looping through all windows.

**Why:** Calling `makeKeyAndOrderFront()` on multiple windows in a loop can create focus conflicts and interfere with input handling.

**How to apply:** Use `windows.first(where:)` to find the specific window you need (e.g., main content window at `.normal` level), then activate only that one.

**Related:** [MenuBarView.swift](ToDo/Presentation/MenuBar/MenuBarView.swift)

---

*Add new lessons above this line*
