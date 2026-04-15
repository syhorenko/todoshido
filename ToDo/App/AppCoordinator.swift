//
//  AppCoordinator.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI
import Combine
import Carbon

/// Main app coordinator managing view creation and dependency injection
/// Implements the Coordinator pattern to decouple view construction from views
@MainActor
final class AppCoordinator: ObservableObject {
    private let repository: TodoRepository
    private let hotkeyService: HotkeyService
    private let captureUseCase: CaptureTodoFromClipboardUseCase
    private let preferencesService: PreferencesService
    private let launchAtLoginService: LaunchAtLoginService
    private let cloudSyncStatusService: CloudSyncStatusService
    private let cloudSyncMonitor: CloudKitSyncMonitor

    // Published state for capture HUD
    @Published var captureMessage: String?
    @Published var captureType: CaptureHUDView.CaptureResultType?

    // Preferences subscription
    private var preferencesSubscription: AnyCancellable?

    init(
        repository: TodoRepository,
        hotkeyService: HotkeyService,
        pasteboardService: PasteboardService,
        activeAppService: ActiveApplicationService
    ) {
        self.repository = repository
        self.hotkeyService = hotkeyService

        // Initialize services
        self.preferencesService = UserDefaultsPreferencesService()
        self.launchAtLoginService = SMAppLaunchAtLoginService()

        // Initialize CloudKit sync monitor
        let persistenceController = PersistenceController.shared
        self.cloudSyncMonitor = CloudKitSyncMonitor(
            container: persistenceController.container
        )
        self.cloudSyncStatusService = CloudKitSyncStatusService(
            monitor: cloudSyncMonitor
        )

        let createUseCase = CreateTodoUseCase(repository: repository)
        self.captureUseCase = CaptureTodoFromClipboardUseCase(
            pasteboardService: pasteboardService,
            activeAppService: activeAppService,
            createUseCase: createUseCase,
            preferencesService: preferencesService
        )

        setupHotkey()
        subscribeToPreferenceChanges()
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

    /// Create Settings view with injected dependencies
    func makeSettingsView() -> SettingsView {
        let viewModel = SettingsViewModel(
            preferencesService: preferencesService,
            launchAtLoginService: launchAtLoginService,
            cloudSyncStatusService: cloudSyncStatusService
        )

        return SettingsView(viewModel: viewModel)
    }

    // MARK: - Hotkey Setup

    private func setupHotkey() {
        let prefs = preferencesService.preferences
        let config = HotkeyConfiguration(
            keyCode: prefs.hotkeyKeyCode,
            modifiers: prefs.hotkeyModifiers,
            identifier: "com.todoshido.capture"
        )

        do {
            try hotkeyService.register(configuration: config, handler: { [weak self] in
                Task { @MainActor in
                    await self?.handleCapture()
                }
            })
            let displayString = HotkeyFormatter.displayString(
                modifiers: config.modifiers,
                keyCode: config.keyCode
            )
            Logger.info("Hotkey registered: \(displayString)", category: "coordinator")
        } catch {
            Logger.error("Failed to register hotkey: \(error)", category: "coordinator")
        }
    }

    private func subscribeToPreferenceChanges() {
        guard let concreteService = preferencesService as? UserDefaultsPreferencesService else {
            return
        }

        preferencesSubscription = concreteService.$preferences
            .dropFirst()  // Skip initial value
            .sink { [weak self] newPrefs in
                Task { @MainActor [weak self] in
                    await self?.updateHotkey(
                        keyCode: newPrefs.hotkeyKeyCode,
                        modifiers: newPrefs.hotkeyModifiers
                    )
                }
            }
    }

    private func updateHotkey(keyCode: UInt32, modifiers: UInt32) async {
        // Unregister current hotkey
        hotkeyService.unregister(identifier: "com.todoshido.capture")

        // Register new hotkey
        let config = HotkeyConfiguration(
            keyCode: keyCode,
            modifiers: modifiers,
            identifier: "com.todoshido.capture"
        )

        do {
            try hotkeyService.register(configuration: config, handler: { [weak self] in
                Task { @MainActor in
                    await self?.handleCapture()
                }
            })
            let displayString = HotkeyFormatter.displayString(
                modifiers: modifiers,
                keyCode: keyCode
            )
            Logger.info("Hotkey updated to \(displayString)", category: "coordinator")
        } catch {
            Logger.error("Failed to register new hotkey: \(error)", category: "coordinator")

            // Fallback to default on error
            let defaultConfig = HotkeyConfiguration.captureShortcut
            try? hotkeyService.register(configuration: defaultConfig, handler: { [weak self] in
                Task { @MainActor in
                    await self?.handleCapture()
                }
            })
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
