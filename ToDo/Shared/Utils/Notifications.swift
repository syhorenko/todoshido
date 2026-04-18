//
//  Notifications.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// App-wide notification names
extension Notification.Name {
    /// Posted when a new todo is captured via clipboard
    static let todoCaptured = Notification.Name("todoCaptured")

    /// Posted when todos are modified (created, completed, deleted, updated)
    /// This allows different views to stay in sync
    static let todosChanged = Notification.Name("todosChanged")

    /// Posted when a specific todo should be selected and focused in the main window
    static let selectTodoItem = Notification.Name("selectTodoItem")

    /// Posted when the main window should be opened (if closed)
    static let openMainWindow = Notification.Name("openMainWindow")
}

/// Helper methods for working with notifications
extension Notification {
    /// Post notification to select a specific todo item
    /// - Parameter todoId: UUID of the todo to select
    static func postSelectTodoItem(_ todoId: UUID) {
        NotificationCenter.default.post(
            name: .selectTodoItem,
            object: nil,
            userInfo: ["todoId": todoId]
        )
    }

    /// Extract todo ID from selectTodoItem notification
    var selectedTodoId: UUID? {
        guard name == .selectTodoItem,
              let todoId = userInfo?["todoId"] as? UUID else {
            return nil
        }
        return todoId
    }
}
