# Module Checklist

Quick reference checklist for creating new features in the ToDo iOS app.

---

## When Creating a New Feature

### 1. Plan the Data Model

- [ ] Define model properties (stored properties only)
- [ ] Add `@Model` macro to class
- [ ] Use `final class` keyword
- [ ] Import `SwiftData` and `Foundation`
- [ ] Create explicit initializer
- [ ] Register model in `Schema` in app file
- [ ] Define relationships if needed (with delete rules)
- [ ] Add computed properties for derived data

**Example:**
```swift
import Foundation
import SwiftData

@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}
```

---

### 2. Create the View

- [ ] Import `SwiftUI` and `SwiftData`
- [ ] Add file header comment with filename, project, author
- [ ] Define view struct conforming to `View`
- [ ] Add `@Environment(\.modelContext)` if CRUD operations needed
- [ ] Add `@Query` for data fetching
- [ ] Implement `body` property with view content
- [ ] Wrap mutations in `withAnimation { }`
- [ ] Add cross-platform checks with `#if os(iOS)` if needed
- [ ] Create `#Preview` at the end

**Example:**
```swift
//
//  TodoListView.swift
//  ToDo
//
//  Created by [Author] on [Date].
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt) private var items: [TodoItem]
    
    var body: some View {
        List {
            ForEach(items) { item in
                Text(item.title)
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
```

---

### 3. Add Navigation

- [ ] Wrap content in `NavigationViewWrapper` if needed
- [ ] Add `NavigationLink` for detail views
- [ ] Add toolbar items with `.toolbar { }`
- [ ] Use platform-specific toolbar placement if needed

---

### 4. Testing Checklist

- [ ] Build the project successfully (`⌘ + B`)
- [ ] Preview works in Xcode canvas
- [ ] Test on iOS simulator
- [ ] Test on macOS if cross-platform
- [ ] Test CRUD operations (Create, Read, Update, Delete)
- [ ] Test with empty state
- [ ] Test with multiple items
- [ ] Verify animations are smooth

---

### 5. Code Quality

- [ ] All files have proper headers
- [ ] Code follows Swift naming conventions
- [ ] No force unwraps (`!`) unless absolutely necessary
- [ ] Proper error handling where needed
- [ ] No compiler warnings
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Add `#Preview` to all custom views

---

## Common Patterns Quick Reference

### Add Item Function
```swift
private func addItem() {
    withAnimation {
        let newItem = TodoItem(title: "New Task")
        modelContext.insert(newItem)
    }
}
```

### Delete Items Function
```swift
private func deleteItems(offsets: IndexSet) {
    withAnimation {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
```

### Toggle Boolean Property
```swift
private func toggleItem(_ item: TodoItem) {
    withAnimation {
        item.isCompleted.toggle()
    }
}
```

### Query with Filter
```swift
@Query(filter: #Predicate<TodoItem> { $0.isCompleted == false })
private var activeItems: [TodoItem]
```

### Cross-Platform Toolbar
```swift
.toolbar {
#if os(iOS)
    ToolbarItem(placement: .navigationBarTrailing) {
        EditButton()
    }
#endif
    ToolbarItem {
        Button(action: addItem) {
            Label("Add", systemImage: "plus")
        }
    }
}
```

---

## Project Structure

```
ToDo/
├── ToDoApp.swift           # App entry point, model container setup
├── Models/                 # SwiftData models
│   └── TodoItem.swift
├── Views/                  # SwiftUI views
│   ├── TodoListView.swift
│   └── TodoDetailView.swift
├── Assets.xcassets/        # Images, colors, etc.
└── Info.plist             # App configuration
```

---

## Build Commands

```bash
# Build project
xcodebuild -project ToDo.xcodeproj -scheme ToDo build

# Clean build
xcodebuild -project ToDo.xcodeproj -scheme ToDo clean build

# Run tests
xcodebuild -project ToDo.xcodeproj -scheme ToDo test
```

---

## Key Reminders

1. **Always wrap mutations in `withAnimation`**
2. **Use `@Query` for automatic UI updates**
3. **Register all models in Schema**
4. **Provide previews for all views**
5. **Use `final class` for models**
6. **Test on both platforms if cross-platform**
