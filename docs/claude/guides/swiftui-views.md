# SwiftUI Views

This guide covers SwiftUI view patterns used in the ToDo iOS app.

## Overview

This project uses **SwiftUI** as the UI framework with **SwiftData** for persistence. Views are declarative and follow SwiftUI conventions.

---

## File Header Pattern

All Swift files follow this header structure:

```swift
//
//  FileName.swift
//  ToDo
//
//  Created by [Author] on [Date].
//

import SwiftUI
import SwiftData // if needed
```

---

## Basic View Pattern

### Simple View Structure

```swift
import SwiftUI

struct FeatureView: View {
    var body: some View {
        // View content here
        Text("Hello, World!")
    }
}

#Preview {
    FeatureView()
}
```

### View with State Management

```swift
import SwiftUI
import SwiftData

struct FeatureView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isShowingSheet = false
    
    var body: some View {
        NavigationViewWrapper {
            List {
                ForEach(items) { item in
                    ItemRow(item: item)
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
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
```

---

## Cross-Platform Patterns

### Platform-Specific UI with Compiler Directives

```swift
struct FeatureView: View {
    var body: some View {
        List {
            // Shared content
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }
}
```

### Navigation Wrapper for Cross-Platform Support

```swift
fileprivate struct NavigationViewWrapper<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
#if os(macOS)
        NavigationSplitView {
            content()
        } detail: {
            Text("Select an item")
        }
#else
        content()
#endif
    }
}

// Usage:
NavigationViewWrapper {
    List {
        // Content
    }
}
```

---

## SwiftData Integration

### Environment and Query

```swift
struct FeatureView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    // Use items array directly - it's automatically updated
}
```

### Model Container Setup (in App file)

```swift
import SwiftUI
import SwiftData

@main
struct ToDoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## Navigation Patterns

### NavigationLink for Detail Views

```swift
List {
    ForEach(items) { item in
        NavigationLink {
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
        } label: {
            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
    }
}
```

---

## Preview Patterns

### Basic Preview

```swift
#Preview {
    FeatureView()
}
```

### Preview with SwiftData

```swift
#Preview {
    FeatureView()
        .modelContainer(for: Item.self, inMemory: true)
}
```

---

## Key Points

- **Always use `#Preview`** for SwiftUI previews (modern syntax)
- **Environment objects** are accessed with `@Environment(\.modelContext)`
- **Queries** use `@Query` property wrapper for automatic updates
- **Animations** wrap state changes with `withAnimation { }`
- **Cross-platform** code uses `#if os(iOS)` or `#if os(macOS)` compiler directives
- **Navigation** uses `NavigationLink` for hierarchical navigation
- **Toolbar items** use `.toolbar { }` modifier
- **File headers** include filename, project name, and author

---

## Common Mistakes to Avoid

- Don't forget to wrap mutations in `withAnimation { }` for smooth UI updates
- Always provide a preview for every custom view
- Use `@Query` instead of manually fetching from model context
- Don't access model context directly unless inserting/deleting
