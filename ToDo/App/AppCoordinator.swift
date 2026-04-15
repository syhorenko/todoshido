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
    private let hotkeyService: HotkeyService
    private let captureUseCase: CaptureTodoFromClipboardUseCase

    // Published state for capture HUD
    @Published var captureMessage: String?
    @Published var captureType: CaptureHUDView.CaptureResultType?

    init(
        repository: TodoRepository,
        hotkeyService: HotkeyService,
        pasteboardService: PasteboardService,
        activeAppService: ActiveApplicationService
    ) {
        self.repository = repository
        self.hotkeyService = hotkeyService

        let createUseCase = CreateTodoUseCase(repository: repository)
        self.captureUseCase = CaptureTodoFromClipboardUseCase(
            pasteboardService: pasteboardService,
            activeAppService: activeAppService,
            createUseCase: createUseCase
        )

        setupHotkey()
    }

    /// Create Inbox view with injected dependencies
    func makeInboxView() -> InboxView {
        let fetchUseCase = FetchOpenTodosGroupedUseCase(repository: repository)
        let createUseCase = CreateTodoUseCase(repository: repository)
        let completeUseCase = CompleteTodoUseCase(repository: repository)
        let deleteUseCase = DeleteTodoUseCase(repository: repository)

        let viewModel = InboxViewModel(
            fetchUseCase: fetchUseCase,
            createUseCase: createUseCase,
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

    /// Create Menu Bar view with injected dependencies
    func makeMenuBarView() -> MenuBarView {
        let fetchUseCase = FetchRecentTodosUseCase(repository: repository)
        let completeUseCase = CompleteTodoUseCase(repository: repository)
        let createUseCase = CreateTodoUseCase(repository: repository)

        let viewModel = MenuBarViewModel(
            fetchUseCase: fetchUseCase,
            completeUseCase: completeUseCase,
            createUseCase: createUseCase
        )

        return MenuBarView(viewModel: viewModel)
    }

    // MARK: - Hotkey Setup

    private func setupHotkey() {
        do {
            try hotkeyService.register(
                configuration: .captureShortcut,
                handler: { [weak self] in
                    Task { @MainActor in
                        await self?.handleCapture()
                    }
                }
            )
            Logger.info("Hotkey registered: Cmd+Shift+T", category: "coordinator")
        } catch {
            Logger.error("Failed to register hotkey: \(error)", category: "coordinator")
        }
    }

    // MARK: - Capture Handling

    func handleCapture() async {
        do {
            let item = try await captureUseCase.execute()
            showCaptureSuccess(text: item.text)

            // Notify views to refresh
            NotificationCenter.default.post(name: .todoCaptured, object: nil)
        } catch CaptureTodoFromClipboardUseCase.CaptureError.clipboardEmpty {
            showCaptureError(message: "Clipboard is empty")
        } catch CaptureTodoFromClipboardUseCase.CaptureError.duplicateCapture {
            // Silent ignore - duplicate detection prevents noise
            Logger.debug("Duplicate capture suppressed", category: "capture")
        } catch {
            showCaptureError(message: "Failed to capture")
            Logger.error("Capture failed: \(error)", category: "capture")
        }
    }

    private func showCaptureSuccess(text: String) {
        let truncated = text.prefix(40)
        captureMessage = "Captured: \(truncated)\(text.count > 40 ? "..." : "")"
        captureType = .success
        clearCaptureMessage()
    }

    private func showCaptureError(message: String) {
        captureMessage = message
        captureType = .error
        clearCaptureMessage()
    }

    private func clearCaptureMessage() {
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 seconds
            captureMessage = nil
            captureType = nil
        }
    }
}
