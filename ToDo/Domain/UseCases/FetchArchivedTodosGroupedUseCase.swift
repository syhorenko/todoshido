//
//  FetchArchivedTodosGroupedUseCase.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for fetching archived todos grouped by completion date
final class FetchArchivedTodosGroupedUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Fetch all archived todos grouped by completion date
    /// - Returns: Array of TodoGroup sorted newest to oldest
    func execute() async throws -> [TodoGroup] {
        let todos = try await repository.fetchArchivedTodos()

        // Group by start of day (completedAt, fallback to createdAt)
        let grouped = Dictionary(grouping: todos) { todo in
            let dateToGroup = todo.completedAt ?? todo.createdAt
            return Calendar.current.startOfDay(for: dateToGroup)
        }

        // Convert to TodoGroup and sort newest first
        let groups = grouped
            .map { date, items in
                TodoGroup(
                    id: ISO8601DateFormatter().string(from: date),
                    title: date.sectionTitle,
                    date: date,
                    items: items.sorted {
                        let date1 = $0.completedAt ?? $0.createdAt
                        let date2 = $1.completedAt ?? $1.createdAt
                        return date1 > date2
                    }
                )
            }
            .sorted { $0.date > $1.date }

        Logger.debug("Fetched \(todos.count) archived todos in \(groups.count) groups", category: "usecase")

        return groups
    }
}
