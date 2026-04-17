//
//  MockTodoRepository.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// In-memory implementation of TodoRepository for SwiftUI previews and testing
final class MockTodoRepository: TodoRepository {
    private var items: [TodoItem] = []
    private let queue = DispatchQueue(label: "com.todoshido.mockrepository")

    init(preloadSampleData: Bool = true) {
        if preloadSampleData {
            loadSampleData()
        }
    }

    private func loadSampleData() {
        let now = Date()
        let calendar = Calendar.current

        // Today's items
        items.append(TodoItem(
            id: UUID(),
            text: "Review pull request for new feature",
            createdAt: calendar.date(byAdding: .hour, value: -2, to: now)!,
            updatedAt: calendar.date(byAdding: .hour, value: -2, to: now)!,
            completedAt: nil,
            status: .active,
            sourceAppName: "GitHub",
            sourceBundleID: "com.github.desktop",
            captureMethod: .clipboardShortcut
        ))

        items.append(TodoItem(
            id: UUID(),
            text: "Update project documentation",
            createdAt: calendar.date(byAdding: .hour, value: -5, to: now)!,
            updatedAt: calendar.date(byAdding: .hour, value: -5, to: now)!,
            completedAt: nil,
            status: .active,
            sourceAppName: nil,
            sourceBundleID: nil,
            captureMethod: .manualEntry
        ))

        // Yesterday's items
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        items.append(TodoItem(
            id: UUID(),
            text: "Schedule team standup for next week",
            createdAt: calendar.date(byAdding: .hour, value: -10, to: yesterday)!,
            updatedAt: calendar.date(byAdding: .hour, value: -10, to: yesterday)!,
            completedAt: nil,
            status: .active,
            sourceAppName: "Slack",
            sourceBundleID: "com.tinyspeck.slackmacgap",
            captureMethod: .clipboardShortcut
        ))

        // Older items
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        items.append(TodoItem(
            id: UUID(),
            text: "Research new logging framework options",
            createdAt: threeDaysAgo,
            updatedAt: threeDaysAgo,
            completedAt: nil,
            status: .active,
            sourceAppName: nil,
            sourceBundleID: nil,
            captureMethod: .manualEntry
        ))

        // Archived items
        items.append(TodoItem(
            id: UUID(),
            text: "Fix navigation bug in iOS app",
            createdAt: calendar.date(byAdding: .day, value: -2, to: now)!,
            updatedAt: now,
            completedAt: now,
            status: .archived,
            sourceAppName: "Linear",
            sourceBundleID: "com.linear.app",
            captureMethod: .clipboardShortcut
        ))

        items.append(TodoItem(
            id: UUID(),
            text: "Complete code review checklist",
            createdAt: yesterday,
            updatedAt: yesterday,
            completedAt: yesterday,
            status: .archived,
            sourceAppName: nil,
            sourceBundleID: nil,
            captureMethod: .manualEntry
        ))
    }

    func fetchOpenTodos() async throws -> [TodoItem] {
        queue.sync {
            items
                .filter { !$0.status.isArchived }
                .sorted { $0.createdAt > $1.createdAt }
        }
    }

    func fetchArchivedTodos() async throws -> [TodoItem] {
        queue.sync {
            items
                .filter { $0.status.isArchived }
                .sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }
        }
    }

    func fetchAllTodos() async throws -> [TodoItem] {
        queue.sync {
            items.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func createTodo(_ item: TodoItem) async throws {
        queue.sync {
            items.append(item)
        }
    }

    func updateTodo(_ item: TodoItem) async throws {
        try queue.sync {
            guard let index = items.firstIndex(where: { $0.id == item.id }) else {
                throw RepositoryError.itemNotFound(item.id)
            }
            items[index] = item
        }
    }

    func deleteTodo(id: UUID) async throws {
        try queue.sync {
            guard let index = items.firstIndex(where: { $0.id == id }) else {
                throw RepositoryError.itemNotFound(id)
            }
            items.remove(at: index)
        }
    }
}
