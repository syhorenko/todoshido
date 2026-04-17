//
//  TodoExport.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Data transfer object for exporting/importing todos
struct TodoExport: Codable {
    /// Schema version for future compatibility
    let version: Int

    /// When this export was created
    let exportDate: Date

    /// Total number of todos
    let itemCount: Int

    /// All todos (active and archived)
    let todos: [TodoItem]

    /// Create export from array of todos
    /// - Parameter todos: Array of todos to export
    /// - Returns: TodoExport DTO with metadata
    static func create(from todos: [TodoItem]) -> TodoExport {
        TodoExport(
            version: 1,
            exportDate: Date(),
            itemCount: todos.count,
            todos: todos
        )
    }
}
