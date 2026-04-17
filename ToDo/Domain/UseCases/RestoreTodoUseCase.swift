//
//  RestoreTodoUseCase.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for restoring an archived todo back to active state
final class RestoreTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Restore an archived todo back to active status
    /// - Parameter item: The todo item to restore
    func execute(_ item: TodoItem) async throws {
        let now = Date()

        var updated = item
        updated.status = .active
        updated.completedAt = nil
        updated.updatedAt = now

        try await repository.updateTodo(updated)
        Logger.info("Restored todo: \(item.id)", category: "usecase")
    }
}
