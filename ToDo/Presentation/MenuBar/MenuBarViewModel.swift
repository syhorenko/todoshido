//
//  MenuBarViewModel.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// View model for Menu Bar
/// Manages state and business logic for displaying recent todos in menu bar
@MainActor
final class MenuBarViewModel: ObservableObject {
    @Published var recentTodos: [TodoItem] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let fetchUseCase: FetchRecentTodosUseCase
    private let completeUseCase: CompleteTodoUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchUseCase: FetchRecentTodosUseCase,
        completeUseCase: CompleteTodoUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.completeUseCase = completeUseCase

        // Listen for capture notifications to auto-refresh
        NotificationCenter.default.publisher(for: .todoCaptured)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.load()
                }
            }
            .store(in: &cancellables)
    }

    /// Load recent todos
    func load() async {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            recentTodos = try await fetchUseCase.execute(limit: 10)
        } catch {
            self.error = error
            Logger.error("Failed to load recent todos: \(error)", category: "menubar")
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
            Logger.error("Failed to complete todo: \(error)", category: "menubar")
        }
    }
}
