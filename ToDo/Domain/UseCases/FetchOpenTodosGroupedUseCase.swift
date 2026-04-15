//
//  FetchOpenTodosGroupedUseCase.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Use case for fetching open todos grouped by creation date
final class FetchOpenTodosGroupedUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Fetch all open (non-archived) todos grouped by creation date
    /// - Returns: Array of TodoGroup sorted newest to oldest
    func execute() async throws -> [TodoGroup] {
        let todos = try await repository.fetchOpenTodos()

        // Group by start of day (createdAt)
        let grouped = Dictionary(grouping: todos) { todo in
            Calendar.current.startOfDay(for: todo.createdAt)
        }

        // Convert to TodoGroup and sort newest first
        let groups = grouped
            .map { date, items in
                TodoGroup(
                    id: ISO8601DateFormatter().string(from: date),
                    title: date.sectionTitle,
                    date: date,
                    items: items.sorted { $0.createdAt > $1.createdAt }
                )
            }
            .sorted { $0.date > $1.date }

        Logger.debug("Fetched \(todos.count) open todos in \(groups.count) groups", category: "usecase")

        return groups
    }
}
