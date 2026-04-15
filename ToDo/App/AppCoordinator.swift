//
//  AppCoordinator.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI
import Combine

/// Main app coordinator managing view creation and dependency injection
/// Implements the Coordinator pattern to decouple view construction from views
@MainActor
final class AppCoordinator: ObservableObject {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Create Inbox view with injected dependencies
    func makeInboxView() -> InboxView {
        let fetchUseCase = FetchOpenTodosGroupedUseCase(repository: repository)
        let completeUseCase = CompleteTodoUseCase(repository: repository)
        let deleteUseCase = DeleteTodoUseCase(repository: repository)

        let viewModel = InboxViewModel(
            fetchUseCase: fetchUseCase,
            completeUseCase: completeUseCase,
            deleteUseCase: deleteUseCase
        )

        return InboxView(viewModel: viewModel)
    }

    /// Create Archive view with injected dependencies
    func makeArchiveView() -> ArchiveView {
        let fetchUseCase = FetchArchivedTodosGroupedUseCase(repository: repository)
        let restoreUseCase = RestoreTodoUseCase(repository: repository)
        let deleteUseCase = DeleteTodoUseCase(repository: repository)

        let viewModel = ArchiveViewModel(
            fetchUseCase: fetchUseCase,
            restoreUseCase: restoreUseCase,
            deleteUseCase: deleteUseCase
        )

        return ArchiveView(viewModel: viewModel)
    }
}
