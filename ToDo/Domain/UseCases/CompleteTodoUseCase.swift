//
//  CompleteTodoUseCase.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for marking a todo item as complete and archiving it
final class CompleteTodoUseCase {
    private let repository: TodoRepository
    private let soundService: SoundService?

    init(repository: TodoRepository, soundService: SoundService? = nil) {
        self.repository = repository
        self.soundService = soundService
    }

    /// Mark a todo item as complete and archive it
    /// - Parameter item: The todo item to complete
    func execute(_ item: TodoItem) async throws {
        let now = Date()

        var updated = item
        updated.status = .archived
        updated.completedAt = now
        updated.updatedAt = now

        try await repository.updateTodo(updated)
        Logger.info("Completed todo: \(item.id)", category: "usecase")

        soundService?.playTaskCompleted()
    }
}
