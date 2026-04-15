//
//  TodoItem.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Domain model for a todo item
/// Clean Swift model independent of persistence layer
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
    var priority: TodoPriority

    init(
        id: UUID = UUID(),
        text: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil,
        status: TodoStatus = .active,
        sourceAppName: String? = nil,
        sourceBundleID: String? = nil,
        captureMethod: CaptureMethod = .manualEntry,
        priority: TodoPriority = .normal
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
        self.status = status
        self.sourceAppName = sourceAppName
        self.sourceBundleID = sourceBundleID
        self.captureMethod = captureMethod
        self.priority = priority
    }
}
