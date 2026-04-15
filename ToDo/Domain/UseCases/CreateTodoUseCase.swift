//
//  CreateTodoUseCase.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Use case for creating a new todo item
final class CreateTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Create a new todo item with the given text and capture method
    /// - Parameters:
    ///   - text: The todo item text
    ///   - captureMethod: How the todo was captured
    ///   - sourceAppName: Optional name of source application
    ///   - sourceBundleID: Optional bundle ID of source application
    /// - Returns: The created todo item
    func execute(
        text: String,
        captureMethod: CaptureMethod,
        sourceAppName: String? = nil,
        sourceBundleID: String? = nil
    ) async throws -> TodoItem {
        let now = Date()

        let item = TodoItem(
            id: UUID(),
            text: text,
            createdAt: now,
            updatedAt: now,
            completedAt: nil,
            status: .active,
            sourceAppName: sourceAppName,
            sourceBundleID: sourceBundleID,
            captureMethod: captureMethod
        )

        try await repository.createTodo(item)
        Logger.info("Created todo via \(captureMethod): \(text.prefix(50))", category: "usecase")

        return item
    }
}
