# SwiftData Models

This guide covers SwiftData model patterns used in the ToDo iOS app.

## Overview

This project uses **SwiftData** for data persistence. Models are defined using the `@Model` macro and stored automatically.

---

## Basic Model Pattern

### Simple Model

```swift
import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
```

---

## Model Definition Rules

### Required Elements

1. **Import SwiftData**
2. **Use `@Model` macro** on the class
3. **Use `final class`** (recommended for performance)
4. **Provide initializer** for all stored properties

### Extended Model Example

```swift
import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var notes: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var dueDate: Date?
    
    init(
        title: String,
        notes: String? = nil,
        isCompleted: Bool = false,
        dueDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
    }
}
```

---

## Relationships

### One-to-Many Relationship

```swift
@Model
final class Category {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [TodoItem]
    
    init(name: String) {
        self.name = name
        self.items = []
    }
}

@Model
final class TodoItem {
    var title: String
    var category: Category?
    
    init(title: String, category: Category? = nil) {
        self.title = title
        self.category = category
    }
}
```

### Delete Rules

- `.cascade` - Delete related objects when parent is deleted
- `.nullify` - Set relationship to nil when parent is deleted
- `.deny` - Prevent deletion if relationships exist

---

## Schema Configuration

### Registering Models (in App file)

```swift
import SwiftUI
import SwiftData

@main
struct ToDoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            // Add more models here
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema, 
                configurations: [modelConfiguration]
            )
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

## Querying Data

### Basic Query in View

```swift
import SwiftUI
import SwiftData

struct ItemListView: View {
    @Query private var items: [Item]
    
    var body: some View {
        List(items) { item in
            Text(item.title)
        }
    }
}
```

### Query with Sorting

```swift
struct ItemListView: View {
    @Query(sort: \Item.createdAt, order: .reverse) 
    private var items: [Item]
}
```

### Query with Filtering

```swift
struct ItemListView: View {
    @Query(filter: #Predicate<Item> { item in
        item.isCompleted == false
    }, sort: \Item.createdAt) 
    private var activeItems: [Item]
}
```

---

## CRUD Operations

### Insert (Create)

```swift
struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
}
```

### Update

```swift
private func toggleCompletion(item: TodoItem) {
    withAnimation {
        item.isCompleted.toggle()
        item.updatedAt = Date()
    }
}
```

### Delete

```swift
private func deleteItems(offsets: IndexSet) {
    withAnimation {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}
```

### Delete Single Item

```swift
private func deleteItem(_ item: Item) {
    withAnimation {
        modelContext.delete(item)
    }
}
```

---

## Computed Properties

Models can have computed properties:

```swift
@Model
final class TodoItem {
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var displayTitle: String {
        isCompleted ? "✓ \(title)" : title
    }
}
```

---

## Key Points

- **Use `@Model` macro** on model classes
- **All models must be registered** in the Schema
- **Use `@Query`** in views for automatic updates
- **Use `@Environment(\.modelContext)`** for CRUD operations
- **Wrap mutations in `withAnimation`** for smooth UI updates
- **Models must be `final class`** (best practice)
- **Provide explicit initializers** for all properties
- **Use relationships** with appropriate delete rules
- **Computed properties** don't get stored, only stored properties do

---

## Common Mistakes to Avoid

- Don't forget to register new models in the Schema
- Don't mutate model properties without wrapping in `withAnimation`
- Don't use `@Published` with SwiftData models (not needed)
- Don't forget to import SwiftData in both model and view files
- Always use `final` keyword for performance optimization
