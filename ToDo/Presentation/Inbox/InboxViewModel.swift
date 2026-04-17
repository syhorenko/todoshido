//
//  InboxViewModel.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
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
    @Published var editingItem: TodoItem?
    @Published var isRecording = false
    @Published var partialTranscription = ""
    @Published var selectedTodoId: UUID?
    @Published var scrollToId: UUID?

    private let fetchUseCase: FetchOpenTodosGroupedUseCase
    private let createUseCase: CreateTodoUseCase
    private let completeUseCase: CompleteTodoUseCase
    private let deleteUseCase: DeleteTodoUseCase
    private let updatePriorityUseCase: UpdateTodoPriorityUseCase
    private let updateTodoUseCase: UpdateTodoUseCase
    private let voiceCaptureUseCase: CaptureTodoFromVoiceUseCase?
    private var cancellables = Set<AnyCancellable>()

    init(
        fetchUseCase: FetchOpenTodosGroupedUseCase,
        createUseCase: CreateTodoUseCase,
        completeUseCase: CompleteTodoUseCase,
        deleteUseCase: DeleteTodoUseCase,
        updatePriorityUseCase: UpdateTodoPriorityUseCase,
        updateTodoUseCase: UpdateTodoUseCase,
        voiceCaptureUseCase: CaptureTodoFromVoiceUseCase? = nil
    ) {
        self.fetchUseCase = fetchUseCase
        self.createUseCase = createUseCase
        self.completeUseCase = completeUseCase
        self.deleteUseCase = deleteUseCase
        self.updatePriorityUseCase = updatePriorityUseCase
        self.updateTodoUseCase = updateTodoUseCase
        self.voiceCaptureUseCase = voiceCaptureUseCase

        // Listen for capture notifications
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
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
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
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
        } catch {
            self.error = error
            Logger.error("Failed to delete todo: \(error)", category: "inbox")
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
            Logger.error("Failed to create todo: \(error)", category: "inbox")
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
            Logger.error("Failed to change priority: \(error)", category: "inbox")
        }
    }

    /// Edit a todo item's text
    /// - Parameters:
    ///   - item: The todo item to update
    ///   - text: The new text content
    func edit(_ item: TodoItem, text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        do {
            try await updateTodoUseCase.execute(item, text: text)
            await load() // Refresh list
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
        } catch {
            self.error = error
            Logger.error("Failed to edit todo: \(error)", category: "inbox")
        }
    }

    /// Start voice capture for creating a new todo
    func startVoiceCapture() async {
        guard let voiceCaptureUseCase = voiceCaptureUseCase else {
            Logger.error("Voice capture not available", category: "inbox")
            return
        }

        isRecording = true
        partialTranscription = ""

        do {
            _ = try await voiceCaptureUseCase.execute { [weak self] partial in
                Task { @MainActor in
                    self?.partialTranscription = partial
                }
            }
            await load() // Refresh list
            // Notify other views
            NotificationCenter.default.post(name: .todosChanged, object: nil)
            isRecording = false
            partialTranscription = ""
        } catch CaptureTodoFromVoiceUseCase.CaptureError.duplicateCapture {
            // Silent - duplicate detection is intentional
            isRecording = false
            partialTranscription = ""
        } catch {
            self.error = error
            isRecording = false
            partialTranscription = ""
            Logger.error("Voice capture failed: \(error)", category: "inbox")
        }
    }

    /// Stop current voice capture
    func stopVoiceCapture() {
        voiceCaptureUseCase?.stop()
        isRecording = false
        partialTranscription = ""
    }

    /// Select and scroll to a specific todo
    /// - Parameter id: UUID of the todo to select
    func selectTodo(_ id: UUID) {
        selectedTodoId = id
        scrollToId = id

        // Clear selection after 2 seconds
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            selectedTodoId = nil
        }
    }
}
