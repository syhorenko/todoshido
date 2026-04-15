# Project Context

Essential knowledge about the ToDo iOS app.

---

## Project Overview

**Name:** ToDo  
**Purpose:** A simple to-do list application for iOS and macOS  
**Primary Language:** Swift  
**Framework:** SwiftUI + SwiftData  

---

## Technology Stack

### Core Technologies
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Build System:** Xcode

### Key Dependencies
- SwiftUI (built-in)
- SwiftData (built-in)

---

## Architecture

### Patterns Used
- **MVVM (Model-View-ViewModel)** - Implicit in SwiftUI architecture
- **Declarative UI** - SwiftUI's declarative syntax
- **Reactive Data Binding** - `@Query` and `@Environment` property wrappers

### UI Framework
- **Framework:** SwiftUI
- **UI Approach:** Declarative views with automatic updates
- **Data Flow:** SwiftData with `@Query` for reactive updates

---

## Project Structure

### Modules
```
ToDo/
├── ToDoApp.swift          # App entry point, ModelContainer setup
├── ContentView.swift      # Main list view
├── Item.swift             # SwiftData model
├── Assets.xcassets/       # App icons, images, colors
├── ToDo.entitlements      # App capabilities
└── Info.plist            # Configuration
```

### Package/Feature Organization
- Single-module app structure
- Models in root (future: separate Models/ folder)
- Views in root (future: separate Views/ folder)

---

## File Statistics

- **Swift files:** 3
- **Objective-C files:** 0
- **SwiftUI Views:** 1 main view (ContentView)
- **SwiftData Models:** 1 (Item)

---

## Reference Commands

```bash
# Build
xcodebuild -project ToDo.xcodeproj -scheme ToDo build

# Test
xcodebuild -project ToDo.xcodeproj -scheme ToDo test

# Clean build
xcodebuild -project ToDo.xcodeproj -scheme ToDo clean build
```

---

## Key Entry Points

### App Entry Point
- **File:** `ToDoApp.swift`
- **Purpose:** Defines the app structure, sets up SwiftData ModelContainer
- **Key Components:** `@main` app struct, `ModelContainer` configuration

### Main View
- **File:** `ContentView.swift`
- **Purpose:** Primary list view displaying items
- **Key Components:** List with add/delete functionality, cross-platform navigation

### Data Model
- **File:** `Item.swift`
- **Purpose:** SwiftData model representing a to-do item
- **Key Components:** `@Model` macro, timestamp property

---

## Cross-Platform Support

This app supports both **iOS** and **macOS** using conditional compilation:

- Uses `#if os(iOS)` for iOS-specific UI (EditButton in toolbar)
- Uses `#if os(macOS)` for macOS-specific UI (NavigationSplitView)
- `NavigationViewWrapper` provides platform-appropriate navigation

---

## SwiftData Schema

Current models registered in Schema:
- `Item.self`

**Location:** `ToDoApp.swift` - `sharedModelContainer`

---

## Code Conventions

### File Headers
All Swift files include standard headers:
```swift
//
//  FileName.swift
//  ToDo
//
//  Created by [Author] on [Date].
//
```

### Property Wrappers Used
- `@main` - App entry point
- `@Model` - SwiftData models
- `@Environment(\.modelContext)` - Access to model context for CRUD operations
- `@Query` - Automatic data fetching with live updates
- `@State` - Local view state (when needed)

### Animation
All data mutations are wrapped in `withAnimation { }` for smooth UI transitions.

---

**Last Updated:** 2026-04-15
