//
//  InboxViewModel.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// View model for Inbox screen
/// Manages state and business logic for displaying open todos
@MainActor
final class InboxViewModel: ObservableObject {
    @Published var groups: [TodoGroup] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchUseCase: FetchOpenTodosGroupedUseCase
    private let completeUseCase: CompleteTodoUseCase
    private let deleteUseCase: DeleteTodoUseCase

    init(
        fetchUseCase: FetchOpenTodosGroupedUseCase,
        completeUseCase: CompleteTodoUseCase,
        deleteUseCase: DeleteTodoUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.completeUseCase = completeUseCase
        self.deleteUseCase = deleteUseCase
    }

    /// Load open todos grouped by creation date
    func load() async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            groups = try await fetchUseCase.execute()
        } catch {
            self.error = error
            Logger.error("Failed to load open todos: \(error)", category: "inbox")
        }
    }

    /// Mark a todo item as complete
    /// - Parameter item: The todo item to complete
    func complete(_ item: TodoItem) async {
        do {
            try await completeUseCase.execute(item)
            await load() // Refresh list
        } catch {
            self.error = error
            Logger.error("Failed to complete todo: \(error)", category: "inbox")
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
            Logger.error("Failed to delete todo: \(error)", category: "inbox")
        }
    }
}
