//
//  UpdateTodoUseCase.swift
//  ToDo
//
//  Created by Claude on 17/04/2026.
//

import Foundation

/// Use case for updating a todo item's text
final class UpdateTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Update the text of a todo item
    /// - Parameters:
    ///   - item: The todo item to update
    ///   - text: The new text content
    func execute(_ item: TodoItem, text: String) async throws {
        var updated = item
        updated.text = text
        updated.updatedAt = Date()

        try await repository.updateTodo(updated)
        Logger.info("Updated todo text: \(item.id)", category: "usecase")
    }
}
