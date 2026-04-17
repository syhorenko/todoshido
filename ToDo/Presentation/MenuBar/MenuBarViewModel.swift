//
//  MenuBarViewModel.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
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
    private let createUseCase: CreateTodoUseCase
    private let updatePriorityUseCase: UpdateTodoPriorityUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchUseCase: FetchRecentTodosUseCase,
        completeUseCase: CompleteTodoUseCase,
        createUseCase: CreateTodoUseCase,
        updatePriorityUseCase: UpdateTodoPriorityUseCase
    ) {
        self.fetchUseCase = fetchUseCase
        self.completeUseCase = completeUseCase
        self.createUseCase = createUseCase
        self.updatePriorityUseCase = updatePriorityUseCase

        // Listen for capture notifications to auto-refresh
        NotificationCenter.default.publisher(for: .todoCaptured)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.load()
                }
            }
            .store(in: &cancellables)

        // Listen for todos changed notifications (from other views)
        NotificationCenter.default.publisher(for: .todosChanged)
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
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
        } catch {
            self.error = error
            Logger.error("Failed to complete todo: \(error)", category: "menubar")
        }
    }

    /// Create a new todo item
    /// - Parameter text: The todo text
    func create(text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        do {
            _ = try await createUseCase.execute(
                text: text,
                captureMethod: .manualEntry
            )
            await load() // Refresh list
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
        } catch {
            self.error = error
            Logger.error("Failed to create todo from menu bar: \(error)", category: "menubar")
        }
    }

    /// Change priority of a todo item
    /// - Parameters:
    ///   - item: The todo item to update
    ///   - priority: The new priority level
    func changePriority(_ item: TodoItem, to priority: TodoPriority) async {
        do {
            try await updatePriorityUseCase.execute(item, priority: priority)
            await load() // Refresh list
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
        } catch {
            self.error = error
            Logger.error("Failed to change priority: \(error)", category: "menubar")
        }
    }
}
