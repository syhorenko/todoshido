//
//  ArchiveViewModel.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// View model for Archive screen
/// Manages state and business logic for displaying archived todos
@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published var groups: [TodoGroup] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchUseCase: FetchArchivedTodosGroupedUseCase
    private let restoreUseCase: RestoreTodoUseCase
    private let deleteUseCase: DeleteTodoUseCase

    init(
        fetchUseCase: FetchArchivedTodosGroupedUseCase,
        restoreUseCase: RestoreTodoUseCase,
        deleteUseCase: DeleteTodoUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.restoreUseCase = restoreUseCase
        self.deleteUseCase = deleteUseCase
    }

    /// Load archived todos grouped by completion date
    func load() async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            groups = try await fetchUseCase.execute()
        } catch {
            self.error = error
            Logger.error("Failed to load archived todos: \(error)", category: "archive")
        }
    }

    /// Restore an archived todo back to Inbox
    /// - Parameter item: The todo item to restore
    func restore(_ item: TodoItem) async {
        do {
            try await restoreUseCase.execute(item)
            await load() // Refresh list
        } catch {
            self.error = error
            Logger.error("Failed to restore todo: \(error)", category: "archive")
        }
    }

    /// Delete a todo item permanently
    /// - Parameter item: The todo item to delete
    func delete(_ item: TodoItem) async {
        do {
            try await deleteUseCase.execute(id: item.id)
            await load() // Refresh list
        } catch {
            self.error = error
            Logger.error("Failed to delete todo: \(error)", category: "archive")
        }
    }
}
