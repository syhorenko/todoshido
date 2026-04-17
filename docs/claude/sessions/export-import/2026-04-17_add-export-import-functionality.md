# Session: Add Export/Import Functionality for Todos

**Date:** 2026-04-17  
**Topic:** Export/Import Feature

---

## Session Summary

Implemented comprehensive export/import functionality for todos using JSON format. Users can now backup all their todos (both active and archived) to a file and restore them later. The feature uses native macOS file dialogs, exports human-readable JSON with metadata, and imports safely in append mode without destroying existing data.

---

## Changes Made

### Files Created

1. **ToDo/Platform/FileHandling/FileHandlingService.swift**
   - Protocol for file handling operations
   - Defines save panel, open panel, read, and write methods
   - Custom `FileHandlingError` enum with localized descriptions
   - Platform-agnostic interface following established service pattern

2. **ToDo/Platform/FileHandling/CocoaFileHandlingService.swift**
   - Implementation using AppKit (`NSSavePanel`, `NSOpenPanel`)
   - `@MainActor` for thread safety
   - Modal sheet dialogs with fallback to regular modal
   - Atomic file writes to prevent corruption
   - Proper error wrapping

3. **ToDo/Domain/Models/TodoExport.swift**
   - Data Transfer Object (DTO) for JSON export/import
   - Contains metadata: version, exportDate, itemCount
   - Wraps array of `TodoItem` for structured export
   - Static factory method `create(from:)` for convenience

4. **ToDo/Domain/UseCases/ExportTodosUseCase.swift**
   - Use case for exporting todos to JSON file
   - Fetches all todos (open + archived)
   - Encodes to pretty-printed JSON with ISO 8601 dates
   - Shows save panel with default filename pattern
   - Validates non-empty todo list
   - Proper logging

5. **ToDo/Domain/UseCases/ImportTodosUseCase.swift**
   - Use case for importing todos from JSON file
   - Shows open panel for file selection
   - Decodes JSON with error handling
   - Validates version compatibility
   - Appends todos (non-destructive import)
   - Returns count of imported todos

### Files Modified

6. **ToDo/Domain/Models/TodoItem.swift**
   - Added `Codable` conformance to struct
   - Enables automatic JSON encoding/decoding
   - All nested types (TodoStatus, TodoPriority, CaptureMethod) already Codable

7. **ToDo/Presentation/Settings/SettingsViewModel.swift**
   - Added `@Published var successMessage: String?` for success feedback
   - Added `exportUseCase` and `importUseCase` properties (optional)
   - Updated `init()` with optional export/import parameters
   - Added `exportTodos()` method with error handling
   - Added `importTodos()` method with cross-view notification
   - Added `clearSuccessMessage()` helper (3-second auto-dismiss)

8. **ToDo/Presentation/Settings/SettingsView.swift**
   - Added new "Data Management" section after iCloud Sync
   - Two buttons: "Export All Todos" and "Import Todos" with SF Symbols
   - Description text: "Backup and restore your todos"
   - Success message display (green text, auto-dismiss)

9. **ToDo/App/AppCoordinator.swift**
   - Created `CocoaFileHandlingService` in `makeSettingsView()`
   - Created `ExportTodosUseCase` and `ImportTodosUseCase`
   - Injected into `SettingsViewModel` initialization

---

## Key Decisions

### File Format: JSON
- **Decision:** Use JSON with metadata wrapper
- **Rationale:** Human-readable, structured, all models already Codable
- **Structure:** Version, export date, item count, todos array
- **Benefit:** Future-proof (version field), easy to inspect/debug

### Export Scope: All Todos
- **Decision:** Export both active and archived todos
- **Rationale:** User requested "all finished and not finished tasks"
- **Implementation:** Combine `fetchOpenTodos()` + `fetchArchivedTodos()`

### Import Strategy: Append Mode
- **Decision:** Add imported todos without deleting existing ones
- **Rationale:** Safer default, non-destructive
- **Trade-off:** May create duplicates (user can manually clean up)
- **Future Enhancement:** Add "Replace All" option

### UI Integration: Settings
- **Location:** New "Data Management" section in Settings
- **Placement:** After iCloud Sync, before Reset
- **Pattern:** Two side-by-side buttons with icons

### Default Filename Pattern
- **Format:** `Todoshido-Export-YYYY-MM-DD.json`
- **Benefit:** Clear, sortable by date, includes app name

---

## Next Steps

### Testing Checklist
1. **Build**: ✅ Succeeded
2. **Export Flow**:
   - Open Settings → Data Management
   - Click "Export All Todos"
   - Verify save dialog with default filename
   - Save file and inspect JSON structure
3. **Import Flow**:
   - Create test todos
   - Export them
   - Delete some todos
   - Import from saved file
   - Verify todos restored
4. **Edge Cases**:
   - Empty export → error message
   - Cancel dialogs → no error shown
   - Invalid JSON → helpful error
   - Large dataset (1000+ todos)
5. **Cross-view sync**:
   - Import in Settings → Inbox refreshes

### Future Enhancements
- **Replace mode**: Checkbox to replace existing todos instead of append
- **Selective export**: Export only active or only archived
- **CSV format**: For spreadsheet compatibility
- **Auto-backup**: Periodic automatic exports
- **Import preview**: Show what will be imported before confirming
- **Cloud export**: Direct export to iCloud Drive

---

## Commands Reference

```bash
# Build
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido build

# Test export
# 1. Run app
# 2. Open Settings (Cmd+,)
# 3. Scroll to Data Management
# 4. Click "Export All Todos"
# 5. Save file
# 6. Inspect: cat ~/Downloads/Todoshido-Export-*.json | jq '.'

# Test import
# 1. Delete some todos in app
# 2. Click "Import Todos" in Settings
# 3. Select previously exported file
# 4. Verify todos restored

# Commit (when tested)
git add ToDo/Platform/FileHandling/
git add ToDo/Domain/Models/TodoExport.swift
git add ToDo/Domain/Models/TodoItem.swift
git add ToDo/Domain/UseCases/ExportTodosUseCase.swift
git add ToDo/Domain/UseCases/ImportTodosUseCase.swift
git add ToDo/Presentation/Settings/SettingsViewModel.swift
git add ToDo/Presentation/Settings/SettingsView.swift
git add ToDo/App/AppCoordinator.swift
git commit -m "Add export/import functionality for todos

Users can now backup and restore all their todos using JSON files.

Features:
- Export all todos (active + archived) to JSON file
- Import todos from JSON file (append mode)
- Native macOS file dialogs (NSSavePanel/NSOpenPanel)
- Human-readable JSON with metadata (version, date, count)
- Success/error feedback in Settings UI
- Cross-view synchronization after import
- Non-destructive append mode (safe default)

Technical:
- New FileHandlingService platform service
- ExportTodosUseCase and ImportTodosUseCase
- TodoExport DTO with version field for compatibility
- Added Codable conformance to TodoItem
- Default filename: Todoshido-Export-YYYY-MM-DD.json
- ISO 8601 date encoding for compatibility

Architecture:
- Follows Clean Architecture (Platform → Use Case → Domain)
- Protocol-based service pattern
- Optional dependencies for backwards compatibility
- Atomic file writes to prevent corruption

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Technical Notes

### JSON Structure
```json
{
  "version": 1,
  "exportDate": "2026-04-17T16:48:00Z",
  "itemCount": 3,
  "todos": [
    {
      "id": "...",
      "text": "...",
      "createdAt": "2026-04-17T10:00:00Z",
      "updatedAt": "2026-04-17T10:00:00Z",
      "completedAt": null,
      "status": 0,
      "sourceAppName": "Xcode",
      "sourceBundleID": "com.apple.dt.Xcode",
      "captureMethod": 1,
      "priority": 1
    }
  ]
}
```

### Encoding Strategy
- **Pretty printed**: Human-readable with indentation
- **Sorted keys**: Consistent ordering
- **ISO 8601 dates**: `YYYY-MM-DDTHH:MM:SSZ` format

### File Dialog Behavior
- **Modal sheets**: Attached to key window when available
- **Fallback**: Regular modal if no key window
- **Allowed types**: Uses `UTType(filenameExtension:)`
- **Atomic writes**: Prevents partial writes on crash

### Error Handling
- **User cancelled**: Silent (no error shown)
- **File errors**: Wrapped with helpful messages
- **Validation errors**: Clear explanation
- **Success feedback**: 3-second auto-dismiss

### Version Compatibility
- **Current version**: 1
- **Future versions**: Can add fields without breaking old exports
- **Import validation**: Rejects unsupported versions

---

## Architecture Adherence

✅ **Clean Architecture**: Use Cases separated from platform details  
✅ **Platform Services Pattern**: `FileHandlingService` protocol + implementation  
✅ **MVVM**: ViewModel handles business logic, View is declarative  
✅ **Dependency Injection**: All services injected via AppCoordinator  
✅ **Reactive Updates**: Uses `@Published` for UI state  
✅ **Error Handling**: Localized errors with user-friendly messages  
✅ **Logging**: Uses `Logger` for debugging  
✅ **Cross-View Sync**: NotificationCenter for `.todosChanged`  

---

## Lessons Learned

### Codable Conformance
- **Lesson**: Domain models need `Codable` for JSON serialization
- **Solution**: Added `Codable` to `TodoItem` struct
- **Benefit**: Automatic encode/decode with all nested enums already Codable

### File Dialog Best Practices
- **Modal sheets**: Better UX when attached to window
- **Fallback**: Always provide regular modal for edge cases
- **File types**: Use `UTType` for modern file type specification

### Safe Import Strategy
- **Append mode**: Default to non-destructive operations
- **User control**: Let user manually manage duplicates
- **Future**: Could add checkbox for "Replace All" mode

---

**Implementation Time:** ~1.5 hours  
**Files Changed:** 9 (5 new, 4 modified)  
**Lines Added:** ~450  
**Build Status:** ✅ Success  
**Platform:** macOS (cross-platform compatible)
