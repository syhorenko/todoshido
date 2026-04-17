//
//  CreateTodoUseCase.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Use case for creating a new todo item
final class CreateTodoUseCase {
    private let repository: TodoRepository
    private let preferencesService: PreferencesService
    private let soundService: SoundService?

    init(
        repository: TodoRepository,
        preferencesService: PreferencesService,
        soundService: SoundService? = nil
    ) {
        self.repository = repository
        self.preferencesService = preferencesService
        self.soundService = soundService
    }

    /// Create a new todo item with the given text and capture method
    /// - Parameters:
    ///   - text: The todo item text
    ///   - captureMethod: How the todo was captured
    ///   - sourceAppName: Optional name of source application
    ///   - sourceBundleID: Optional bundle ID of source application
    /// - Returns: The created todo item
    func execute(
        text: String,
        captureMethod: CaptureMethod,
        sourceAppName: String? = nil,
        sourceBundleID: String? = nil
    ) async throws -> TodoItem {
        let now = Date()
        let preferences = preferencesService.preferences

        let item = TodoItem(
            id: UUID(),
            text: text,
            createdAt: now,
            updatedAt: now,
            completedAt: nil,
            status: .active,
            sourceAppName: sourceAppName,
            sourceBundleID: sourceBundleID,
            captureMethod: captureMethod,
            priority: preferences.defaultTodoPriority
        )

        Logger.info("Creating todo via \(captureMethod): \(text.prefix(50))", category: "usecase")
        try await repository.createTodo(item)
        Logger.info("Created todo \(item.id) via \(captureMethod) with \(item.priority) priority", category: "usecase")

        soundService?.playTaskCreated()

        return item
    }
}
