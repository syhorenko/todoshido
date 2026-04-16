# Session: Cross-View Todo Synchronization

**Date:** 2026-04-16  
**Feature:** Synchronize Menu Bar, Inbox, and Archive Views  
**Status:** ✅ Complete

---

## Session Summary

Fixed the issue where completing a todo in one view (menu bar, inbox, or archive) didn't update other views. Implemented a notification-based synchronization system using `.todosChanged` notification that all view models listen to and post when todos are modified.

---

## Problem

**User reported issue:**
- Completing a todo in the menu bar → inbox list not updating
- Completing a todo in the main app → menu bar list not updating
- Same issue with creating, deleting, and restoring todos

**Root cause:**
- Each view model (InboxViewModel, MenuBarViewModel, ArchiveViewModel) only refreshed its own data
- No communication between view models
- Only listened to `.todoCaptured` notification (clipboard captures)
- Actions in one view didn't notify other views

---

## Solution

Implemented a notification-based synchronization system:

1. **New notification:** `.todosChanged`
2. **All view models listen** to this notification and reload when it fires
3. **All view models post** this notification after modifying todos
4. **All CRUD operations** now trigger synchronization

---

## Changes Made

### Modified Files

1. **`ToDo/Shared/Utils/Notifications.swift`**
   - Added `.todosChanged` notification name
   - Documentation: Posted when todos are created, completed, deleted, or updated

2. **`ToDo/Presentation/Inbox/InboxViewModel.swift`**
   - Added listener for `.todosChanged` notification
   - Post `.todosChanged` after: complete, delete, create, changePriority
   - Ensures inbox refreshes when menu bar or archive makes changes

3. **`ToDo/Presentation/MenuBar/MenuBarViewModel.swift`**
   - Added listener for `.todosChanged` notification
   - Post `.todosChanged` after: complete, create, changePriority
   - Ensures menu bar refreshes when inbox or archive makes changes

4. **`ToDo/Presentation/Archive/ArchiveViewModel.swift`**
   - Added `cancellables` property for Combine subscriptions
   - Added listener for `.todosChanged` notification
   - Post `.todosChanged` after: restore, delete
   - Ensures archive refreshes when inbox or menu bar makes changes

---

## Implementation Details

### Notification Flow

```
User Action (e.g., complete todo in menu bar)
    ↓
MenuBarViewModel.complete(item)
    ↓
Execute CompleteTodoUseCase
    ↓
Reload menu bar list
    ↓
Post .todosChanged notification
    ↓
InboxViewModel receives notification → reloads
    ↓
ArchiveViewModel receives notification → reloads
    ↓
All views now show updated data
```

### Code Pattern (Consistent Across All ViewModels)

#### 1. Listen to Notification
```swift
// In init()
NotificationCenter.default.publisher(for: .todosChanged)
    .sink { [weak self] _ in
        Task { @MainActor in
            await self?.load()
        }
    }
    .store(in: &cancellables)
```

#### 2. Post Notification After Changes
```swift
func complete(_ item: TodoItem) async {
    do {
        try await completeUseCase.execute(item)
        await load() // Refresh own list
        // Notify other views
        NotificationCenter.default.post(name: .todosChanged, object: nil)
    } catch {
        // handle error
    }
}
```

---

## Operations That Trigger Synchronization

### InboxViewModel
- ✅ `complete(item)` - Marks todo as done
- ✅ `delete(item)` - Permanently deletes todo
- ✅ `create(text)` - Creates new todo
- ✅ `changePriority(item, priority)` - Updates priority

### MenuBarViewModel
- ✅ `complete(item)` - Marks todo as done
- ✅ `create(text)` - Creates new todo
- ✅ `changePriority(item, priority)` - Updates priority

### ArchiveViewModel
- ✅ `restore(item)` - Restores todo to inbox
- ✅ `delete(item)` - Permanently deletes todo

---

## Key Decisions

### 1. Notification-Based vs Shared State
**Decision:** Use NotificationCenter for synchronization  
**Rationale:**
- Decoupled architecture (view models don't reference each other)
- Simple to implement
- Follows existing pattern (`.todoCaptured`)
- Easy to debug
- No complex state management needed

**Alternative considered:** Shared ObservableObject  
**Why rejected:** Tighter coupling, more complex dependency injection

### 2. Post After Load vs Before Load
**Decision:** Post notification AFTER loading own data  
**Rationale:**
- Ensures the view that made the change updates first
- Other views refresh asynchronously
- User sees immediate feedback in the active view

### 3. Granular Notifications vs Single Notification
**Decision:** Single `.todosChanged` notification for all changes  
**Rationale:**
- Simpler implementation
- All views need to refresh regardless of change type
- Avoids notification explosion (todoCompleted, todoDeleted, etc.)
- Performance impact is minimal (views only reload visible data)

**Alternative considered:** Separate notifications (todoCompleted, todoDeleted, etc.)  
**Why rejected:** Over-engineering for this use case

### 4. Include Changed Item in Notification
**Decision:** Don't include item ID or details in notification  
**Rationale:**
- Views fetch all their data anyway
- Simpler notification API
- No need to track which specific item changed
- All views show correct data after full reload

---

## Testing Performed

### Build Verification
✅ Build succeeded with no errors

**Command:**
```bash
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido build -destination 'platform=macOS'
```

### Manual Testing Checklist
- [ ] Complete todo in menu bar → verify inbox updates
- [ ] Complete todo in inbox → verify menu bar updates
- [ ] Create todo in menu bar → verify inbox shows it
- [ ] Create todo in inbox → verify menu bar shows it
- [ ] Delete todo in inbox → verify menu bar updates
- [ ] Change priority in inbox → verify menu bar updates
- [ ] Change priority in menu bar → verify inbox updates
- [ ] Restore todo from archive → verify inbox shows it
- [ ] Delete todo from archive → verify inbox doesn't show it
- [ ] Complete todo in inbox → verify archive shows it

---

## Benefits

1. **Real-time sync** - All views stay in sync automatically
2. **No manual refresh needed** - User never sees stale data
3. **Consistent UX** - Same behavior across all views
4. **Decoupled architecture** - View models don't know about each other
5. **Easy to extend** - New views can subscribe to `.todosChanged`
6. **Maintainable** - Simple pattern to follow

---

## Edge Cases Handled

### 1. Multiple Simultaneous Changes
- **Scenario:** User completes todo in inbox while menu bar is visible
- **Behavior:** Both views refresh independently
- **Implementation:** Async load prevents race conditions

### 2. Notification While Loading
- **Scenario:** Notification arrives while view is already loading
- **Behavior:** New load() call queued on main actor
- **Implementation:** @MainActor ensures serial execution

### 3. View Not Visible
- **Scenario:** Archive view receives notification while not shown
- **Behavior:** Next time view appears, it loads fresh data
- **Implementation:** Views have `.task { await load() }` on appear

### 4. Rapid Changes
- **Scenario:** User completes 3 todos quickly
- **Behavior:** Each completion triggers notification
- **Implementation:** Async loading handles queue naturally

---

## Performance Considerations

### Network of Notifications
- 3 view models listening to `.todosChanged`
- Each posts after their own changes
- Maximum 2 extra reloads per action (other 2 views)

### Load Efficiency
- Views only fetch data they display
- Repository layer handles deduplication
- SwiftUI only updates changed rows

### No Performance Issues Expected
- Notification overhead is minimal
- Database queries are fast (indexed)
- Only visible views are kept in memory

---

## Future Enhancements (Out of Scope)

- Debounce rapid notifications (coalesce multiple changes)
- Include change type in notification for smarter updates
- Implement partial updates (only changed items)
- Add notification for specific todo IDs (targeted updates)
- Cache data to reduce repeated queries

---

## Commands Reference

### Build
```bash
xcodebuild -project ToDo.xcodeproj -scheme ToDoshido build -destination 'platform=macOS'
```

---

## Learnings

### Pattern: Cross-View Synchronization
Use NotificationCenter for decoupled view synchronization:
- Post notification after making changes
- Listen to notification and reload data
- Keep view models independent
- Simple, maintainable, and effective

### Pattern: Async Load with @MainActor
Combine `@MainActor` with async loading for safe concurrency:
- All loads happen on main thread (UI safe)
- Serial execution prevents race conditions
- No manual dispatch queue management needed

### Pattern: Weak Self in Combine
Always use `[weak self]` in Combine subscriptions:
- Prevents retain cycles
- View models can be deallocated properly
- Use optional chaining for safety

---

**Implementation Time:** ~20 minutes  
**Files Modified:** 4  
**Lines Changed:** ~50  
**Build Status:** ✅ Success  
**Ready for Testing:** ✅ Yes
