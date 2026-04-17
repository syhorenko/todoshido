//
//  TodoGroup.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Represents a group of todo items grouped by date
/// Used for rendering sectioned lists in Inbox and Archive views
struct TodoGroup: Identifiable, Equatable {
    /// Unique identifier (ISO8601 formatted date string)
    let id: String

    /// Display title for section header ("Today", "Yesterday", or formatted date)
    let title: String

    /// Start of day date used for grouping
    let date: Date

    /// Todo items in this group, sorted by creation/completion time
    let items: [TodoItem]
}
