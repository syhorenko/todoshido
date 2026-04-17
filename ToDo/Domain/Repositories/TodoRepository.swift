//
//  TodoRepository.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Repository protocol for todo item persistence
/// Abstracts the data layer from domain logic
protocol TodoRepository {
    /// Fetch all open (non-archived) todos
    func fetchOpenTodos() async throws -> [TodoItem]

    /// Fetch all archived (completed) todos
    func fetchArchivedTodos() async throws -> [TodoItem]

    /// Fetch all todos (both open and archived)
    func fetchAllTodos() async throws -> [TodoItem]

    /// Create a new todo item
    func createTodo(_ item: TodoItem) async throws

    /// Update an existing todo item
    func updateTodo(_ item: TodoItem) async throws

    /// Delete a todo item by ID
    func deleteTodo(id: UUID) async throws
}
