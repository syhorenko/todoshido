//
//  Notifications.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// App-wide notification names
extension Notification.Name {
    /// Posted when a new todo is captured via clipboard
    static let todoCaptured = Notification.Name("todoCaptured")

    /// Posted when todos are modified (created, completed, deleted, updated)
    /// This allows different views to stay in sync
    static let todosChanged = Notification.Name("todosChanged")
}
