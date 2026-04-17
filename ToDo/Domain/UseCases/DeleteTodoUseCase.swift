//
//  DeleteTodoUseCase.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for permanently deleting a todo item
final class DeleteTodoUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Permanently delete a todo item
    /// - Parameter id: The UUID of the todo item to delete
    func execute(id: UUID) async throws {
        try await repository.deleteTodo(id: id)
        Logger.info("Deleted todo: \(id)", category: "usecase")
    }
}
