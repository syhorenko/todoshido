//
//  FetchRecentTodosUseCase.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Use case for fetching limited number of recent open todos
/// Returns flat list sorted by creation date (newest first)
final class FetchRecentTodosUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Fetch most recent open todos (newest first)
    /// - Parameter limit: Maximum number of todos to return (default: 10)
    /// - Returns: Array of TodoItem sorted by creation date (newest first)
    func execute(limit: Int = 10) async throws -> [TodoItem] {
        let todos = try await repository.fetchOpenTodos()

        // Sort by createdAt descending and take first N items
        let recent = todos
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)

        Logger.debug("Fetched \(recent.count) recent todos (limit: \(limit))", category: "usecase")

        return Array(recent)
    }
}
