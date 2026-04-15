# ToDo Capture App — Engineering Specification

## 1. Scope

macOS-first app that captures clipboard text via global shortcut, enriches it with context (source app, timestamp), and manages it as a persistent todo list with archive and iCloud sync. iOS will reuse domain/data layers later.

Non-goals (v1): reminders, collaboration, NLP parsing, tags, browser extensions, direct selection capture (Accessibility), widgets.

---

## 2. Screens & Navigation

### 2.1 Main Window (SwiftUI WindowGroup)

**Layout**

- Sidebar (NavigationSplitView)
- Content List
- Detail Panel (optional in v1; inline editing is acceptable)

**Sidebar Sections**

- Inbox (default)
- Today (filtered view of Inbox)
- Archive
- Settings

**Top Bar**

- Search field
- Quick add button
- Sync status indicator (later)

### 2.2 Inbox Screen

**Purpose**: Display active todos grouped by creation day.

**Sections**

- Today
- Yesterday
- Older (by date)

**Row (TodoRowView)**

- Title (1–3 lines, truncated)
- Subtitle: source app + time
- Trailing actions: [Complete] [More]

**Interactions**

- Tap row → edit inline / open detail
- Complete → moves item to Archive with animation
- Context menu: Edit, Copy, Delete

### 2.3 Archive Screen

**Purpose**: Display completed todos grouped by completion day.

**Sections**

- Grouped by completedAt day

**Row**

- Same as Inbox but with dimmed style

**Interactions**

- Restore → moves back to Inbox
- Delete permanently

### 2.4 Menu Bar Popover (MenuBarExtra)

**Purpose**: Quick access & confirmation

**Content**

- Recent 5–10 items
- “Open App” button
- Optional quick add field

**Capture Feedback**

- On capture: show transient HUD/toast or update popover list

### 2.5 Settings Screen

- Configure global shortcut
- Toggle duplicate prevention window (e.g., 10s)
- Launch at login
- iCloud sync status (read-only in v1)

---

## 3. Data Model (Core Data)

### 3.1 Entity: TodoItem

- id: UUID (indexed)
- text: String
- createdAt: Date (indexed)
- updatedAt: Date
- completedAt: Date? (indexed)
- status: Int16 (enum raw)
- sourceAppName: String?
- sourceBundleID: String?
- captureMethod: Int16 (enum raw)
- groupDay: Date (startOfDay for createdAt; indexed)
- isArchived: Bool (derived or stored; keep stored for query simplicity)
- note: String?

**Derived Rules**

- groupDay = startOfDay(createdAt)
- isArchived = (status == archived)

### 3.2 Enums

```swift
enum TodoStatus: Int16 {
  case active
  case done
  case archived
}

enum CaptureMethod: Int16 {
  case clipboardShortcut
  case manualEntry
  case shareExtension // future
  case accessibilitySelection // future
}
```

### 3.3 Indexing

- createdAt
- completedAt
- groupDay
- id

---

## 4. Architecture (MVVM-C)

### 4.1 Modules

```
App/
Presentation/
Coordinators/
Domain/
Data/
Platform/
Shared/
```

### 4.2 Coordinators

- AppCoordinator
- InboxCoordinator
- ArchiveCoordinator
- SettingsCoordinator
- CaptureCoordinator

**Responsibilities**

- Navigation routing
- Window / popover presentation
- Dependency wiring

### 4.3 ViewModels

- InboxViewModel
- ArchiveViewModel
- TodoRowViewModel
- SettingsViewModel

**Responsibilities**

- State management (ObservableObject)
- User intents → UseCases
- Grouping / filtering

### 4.4 Use Cases

- CaptureTodoFromClipboardUseCase
- CreateTodoUseCase
- FetchOpenTodosGroupedUseCase
- FetchArchivedTodosGroupedUseCase
- CompleteTodoUseCase
- RestoreTodoUseCase
- DeleteTodoUseCase
- SearchTodosUseCase

### 4.5 Repositories

```swift
protocol TodoRepository {
  func create(_ item: TodoItemDTO) async throws
  func fetchOpenGrouped() async throws -> [TodoGroup]
  func fetchArchiveGrouped() async throws -> [TodoGroup]
  func update(_ item: TodoItemDTO) async throws
  func delete(id: UUID) async throws
}
```

CoreDataTodoRepository implements this.

### 4.6 Platform Services

- PasteboardService
- HotkeyService
- WorkspaceService
- AccessibilityService (later)

---

## 5. Capture System

### 5.1 Flow

1. Hotkey triggered
2. Read clipboard string
3. Validate (non-empty, dedupe)
4. Get frontmost app
5. Create Todo via UseCase
6. Show feedback

### 5.2 Duplicate Prevention

Rule (v1):

- Same text + same app within N seconds → ignore

### 5.3 Services

```swift
protocol PasteboardService {
  func readString() -> String?
}

protocol WorkspaceService {
  func frontmostApp() -> (name: String?, bundleID: String?)
}
```

---

## 6. Persistence & Sync

### 6.1 Stack

- NSPersistentCloudKitContainer
- Private CloudKit DB

### 6.2 Context Strategy

- Main context (UI)
- Background context (writes)
- Merge policy: NSMergeByPropertyObjectTrump

### 6.3 Sync Requirements

- Offline-first
- Automatic background sync
- Conflict tolerance (last-write-wins acceptable for v1)

---

## 7. UI/UX Spec

### 7.1 Theme Tokens

- Background: #0B0D10
- Surface: #12161B
- Elevated: #181D23
- PrimaryText: #F3F5F7
- SecondaryText: #98A2B3
- Accent: #7C5CFF

### 7.2 Components

- TodoRowView
- SectionHeaderView
- EmptyStateView
- CaptureToastView

### 7.3 Animations

- Insert: fade + slight slide
- Complete: collapse + move to archive

---

## 8. Grouping Logic

### Open Todos

- Group by startOfDay(createdAt)

### Archive

- Group by startOfDay(completedAt)

### Section Titles

- Today
- Yesterday
- Formatted date

---

## 9. Error Handling

- Clipboard empty → no-op
- Save failure → show non-blocking toast
- Sync failure → passive indicator (no blocking UI)

---

## 10. Milestone Checklist

### Milestone 1 — Foundation

-

### Milestone 2 — Core Features

-

### Milestone 3 — Capture

-

### Milestone 4 — Sync

-

### Milestone 5 — Polish

-

---

## 11. Acceptance Criteria (MVP)

- Capture via shortcut creates a todo within <200ms
- Todo appears in Inbox grouped correctly
- Completing moves item to Archive
- Sync reflects changes across 2 Macs within reasonable delay
- No crashes on empty/invalid clipboard

---

## 12. Future Extensions

- Accessibility-based selected text capture
- iOS app (reuse Domain/Data)
- Share Extension
- App Intents
- Tags / filtering

---

## 13. Guiding Principle

Ship a **fast, reliable capture inbox** first. Avoid complex integrations until the core loop is solid.

---

## 14. Start Point — Small Step-by-Step Development Plan

This is the recommended order to start development without getting overwhelmed.

### Step 1 — Create the project and folder structure

Start with a **single macOS app target** in Xcode using:

- Swift
- SwiftUI
- Core Data enabled only if you want Xcode to generate the initial stack

Keep the first version simple: one app target, no packages, no iOS target yet.

### Initial folder structure

```text
ToDoApp/
├── App/
│   ├── ToDoApp.swift
│   ├── AppCoordinator.swift
│   └── AppEnvironment.swift
├── Presentation/
│   ├── Inbox/
│   │   ├── InboxView.swift
│   │   ├── InboxViewModel.swift
│   │   └── Components/
│   │       ├── TodoRowView.swift
│   │       └── SectionHeaderView.swift
│   ├── Archive/
│   │   ├── ArchiveView.swift
│   │   └── ArchiveViewModel.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── SettingsViewModel.swift
│   └── Theme/
│       ├── AppColors.swift
│       ├── AppSpacing.swift
│       └── AppTypography.swift
├── Domain/
│   ├── Models/
│   │   ├── TodoItem.swift
│   │   ├── TodoGroup.swift
│   │   ├── TodoStatus.swift
│   │   └── CaptureMethod.swift
│   ├── UseCases/
│   │   ├── CreateTodoUseCase.swift
│   │   ├── FetchOpenTodosGroupedUseCase.swift
│   │   └── CompleteTodoUseCase.swift
│   └── Repositories/
│       └── TodoRepository.swift
├── Data/
│   ├── Persistence/
│   │   ├── PersistenceController.swift
│   │   ├── CoreDataTodoRepository.swift
│   │   └── ManagedTodoItem+Mapping.swift
│   └── Models/
│       └── ManagedTodoItem.swift
├── Platform/
│   ├── Clipboard/
│   │   └── PasteboardService.swift
│   ├── Workspace/
│   │   └── WorkspaceService.swift
│   └── Hotkeys/
│       └── HotkeyService.swift
├── Shared/
│   ├── Extensions/
│   │   ├── Date+Grouping.swift
│   │   └── View+Styling.swift
│   └── Utils/
│       ├── Constants.swift
│       └── Logger.swift
└── Resources/
```

Do not create everything with full logic on day 1. Create empty files where needed so the structure is visible.

---

### Step 2 — Add the minimum utility files first

Before building screens, create a few small foundation files.

### `AppColors.swift`

Contains dark palette colors used across the app.

Example purpose:

- background color
- surface color
- text colors
- accent color

### `AppSpacing.swift`

Central place for spacing constants.

Example:

```swift
enum AppSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
}
```

### `AppTypography.swift`

Optional helper for font styles.

### `Constants.swift`

Store app-wide constants such as:

- default duplicate detection seconds
- max preview text length
- sidebar width

### `Logger.swift`

A tiny wrapper around `print` or `os.Logger`.

### `Date+Grouping.swift`

Very useful from the beginning.

It should contain helpers like:

- `startOfDay`
- `isToday`
- `isYesterday`
- section title formatting

This file will be used in your first screen almost immediately.

---

### Step 3 — Define the domain models before Core Data

Even if you use Core Data, define your clean Swift models first.

Create these files:

### `TodoStatus.swift`

```swift
enum TodoStatus: Int16 {
    case active
    case done
    case archived
}
```

### `CaptureMethod.swift`

```swift
enum CaptureMethod: Int16 {
    case clipboardShortcut
    case manualEntry
    case shareExtension
    case accessibilitySelection
}
```

### `TodoItem.swift`

Your plain Swift domain model.

Suggested first version:

```swift
struct TodoItem: Identifiable, Equatable {
    let id: UUID
    var text: String
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var status: TodoStatus
    var sourceAppName: String?
    var sourceBundleID: String?
    var captureMethod: CaptureMethod
}
```

### `TodoGroup.swift`

For grouped list rendering.

```swift
struct TodoGroup: Identifiable, Equatable {
    let id: String
    let title: String
    let date: Date
    let items: [TodoItem]
}
```

This is important because your UI should depend on `TodoGroup`, not do grouping directly inside the view.

---

### Step 4 — Make fake data before persistence

Do **not** start with Core Data immediately.

First, make the first screen work with in-memory mock data. That will let you:

- build UI faster
- validate grouping logic
- avoid mixing storage bugs with UI bugs

Create:

### `TodoRepository.swift`

```swift
protocol TodoRepository {
    func fetchOpenTodos() async throws -> [TodoItem]
    func createTodo(_ item: TodoItem) async throws
    func updateTodo(_ item: TodoItem) async throws
    func deleteTodo(id: UUID) async throws
}
```

### `MockTodoRepository.swift`

Put it in `Data/` or `Presentation/PreviewSupport/`.

Use a few hardcoded items with different dates.

This is the fastest clean start.

---

### Step 5 — Build the first screen only: Inbox

This should be your very first actual UI milestone.

Do not build Archive, Settings, menu bar, hotkeys, or sync first.

### First screen goal

A working **Inbox screen** that:

- shows open todos
- groups them by date
- displays dark styling
- lets you tap a complete button

### Files to create now

- `InboxView.swift`
- `InboxViewModel.swift`
- `TodoRowView.swift`
- `SectionHeaderView.swift`

---

### Step 6 — Implement `InboxViewModel`

Responsibilities:

- load todos from repository
- group by day
- expose `[TodoGroup]`
- handle complete action

Suggested state:

```swift
@MainActor
final class InboxViewModel: ObservableObject {
    @Published var groups: [TodoGroup] = []
    @Published var searchText: String = ""

    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    func load() async {
        // fetch, group, assign
    }

    func complete(_ item: TodoItem) async {
        // mark done and reload
    }
}
```

---

### Step 7 — Build `InboxView`

The first version should be simple.

Suggested structure:

- `NavigationStack` or inside main app content
- dark background
- list of grouped sections
- each section contains rows

Pseudo layout:

```swift
struct InboxView: View {
    @StateObject var viewModel: InboxViewModel

    var body: some View {
        List {
            ForEach(viewModel.groups) { group in
                Section(header: SectionHeaderView(title: group.title)) {
                    ForEach(group.items) { item in
                        TodoRowView(item: item) {
                            Task { await viewModel.complete(item) }
                        }
                    }
                }
            }
        }
    }
}
```

Do not worry about perfect custom styling on day 1. First make the data flow work.

---

### Step 8 — Create `TodoRowView`

This file should stay tiny.

Row content:

- main text
- source app name under it
- formatted capture time
- complete button on the right

Keep it reusable. Do not put business logic inside the row.

---

### Step 9 — Add grouping helper logic

This is one of the first important pieces of business behavior.

Create a helper or use case:

### `FetchOpenTodosGroupedUseCase.swift`

Responsibilities:

- fetch open todos
- sort descending by createdAt
- group by `startOfDay`
- convert date to title: Today / Yesterday / formatted date

This keeps grouping out of the view.

---

### Step 10 — Only after that, add Core Data

Once your Inbox screen works with mock data:

- create Core Data entity
- map `ManagedTodoItem` ↔ `TodoItem`
- implement `CoreDataTodoRepository`
- replace mock repository in app environment

This order is much safer than starting with persistence first.

---

## 15. Recommended exact first implementation order

Use this as your checklist for the first few coding sessions.

### Session 1

-

### Session 2

-

### Session 3

-

### Session 4

-

### Session 5

-

### Session 6

-

After that, you will have a real starting product. Only then move to Archive screen, menu bar, shortcut capture, and CloudKit sync.

---

## 16. What not to start with

Avoid starting with these:

- global hotkeys
- menu bar extra
- CloudKit sync
- Accessibility APIs
- iOS target
- settings screen

Those are important later, but they are bad starting points.

The best first milestone is:

**A dark-themed Inbox screen with grouped mock todos and a complete button.**

