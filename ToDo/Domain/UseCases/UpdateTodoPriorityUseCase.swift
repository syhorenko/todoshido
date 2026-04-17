//
//  UpdateTodoPriorityUseCase.swift
//  ToDoshido
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for updating the priority of a todo item
final class UpdateTodoPriorityUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Update the priority of a todo item
    /// - Parameters:
    ///   - item: The todo item to update
    ///   - priority: The new priority level
    func execute(_ item: TodoItem, priority: TodoPriority) async throws {
        var updated = item
        updated.priority = priority
        updated.updatedAt = Date()

        try await repository.updateTodo(updated)
        Logger.info("Updated todo priority: \(item.id) -> \(priority)", category: "usecase")
    }
}
