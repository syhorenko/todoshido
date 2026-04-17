//
//  SettingsViewModel.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import Combine

/// View model for Settings screen
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var preferences: AppPreferences
    @Published var errorMessage: String?
    @Published var syncErrorMessage: String?
    @Published var successMessage: String?

    let preferencesService: PreferencesService
    let launchAtLoginService: LaunchAtLoginService
    let cloudSyncStatusService: CloudSyncStatusService
    private let exportUseCase: ExportTodosUseCase?
    private let importUseCase: ImportTodosUseCase?

    init(
        preferencesService: PreferencesService,
        launchAtLoginService: LaunchAtLoginService,
        cloudSyncStatusService: CloudSyncStatusService,
        exportUseCase: ExportTodosUseCase? = nil,
        importUseCase: ImportTodosUseCase? = nil
    ) {
        self.preferencesService = preferencesService
        self.launchAtLoginService = launchAtLoginService
        self.cloudSyncStatusService = cloudSyncStatusService
        self.exportUseCase = exportUseCase
        self.importUseCase = importUseCase
        self.preferences = preferencesService.preferences

        // Subscribe to sync errors
        if let monitor = (cloudSyncStatusService as? CloudKitSyncStatusService)?.monitor {
            monitor.$userActionableError
                .assign(to: &$syncErrorMessage)
        }
    }

    /// Save preferences to persistence
    func savePreferences() {
        do {
            try preferencesService.update(preferences)
        } catch {
            errorMessage = "Failed to save preferences: \(error.localizedDescription)"
            Logger.error("Failed to save preferences: \(error)", category: "settings")
        }
    }

    /// Reset preferences to defaults
    func resetToDefaults() {
        preferencesService.reset()
        preferences = .default
    }

    /// Toggle launch at login setting
    func toggleLaunchAtLogin() {
        do {
            let newValue = !launchAtLoginService.isEnabled
            try launchAtLoginService.setEnabled(newValue)
            preferences.launchAtLogin = newValue
            savePreferences()
        } catch {
            errorMessage = "Failed to toggle launch at login: \(error.localizedDescription)"
            Logger.error("Failed to toggle launch at login: \(error)", category: "settings")
        }
    }

    /// Export all todos to JSON file
    func exportTodos() {
        guard let exportUseCase = exportUseCase else {
            errorMessage = "Export functionality not available"
            return
        }

        Task {
            do {
                try await exportUseCase.execute()
                successMessage = "Todos exported successfully!"
                clearSuccessMessage()
            } catch FileHandlingError.userCancelled {
                // Silent - user cancelled the save dialog
            } catch {
                errorMessage = error.localizedDescription
                Logger.error("Export failed: \(error)", category: "settings")
            }
        }
    }

    /// Import todos from JSON file
    func importTodos() {
        guard let importUseCase = importUseCase else {
            errorMessage = "Import functionality not available"
            return
        }

        Task {
            do {
                let count = try await importUseCase.execute()
                successMessage = "Successfully imported \(count) todo\(count == 1 ? "" : "s")!"
                clearSuccessMessage()

                // Notify other views to refresh
                NotificationCenter.default.post(name: .todosChanged, object: nil)
            } catch FileHandlingError.userCancelled {
                // Silent - user cancelled the open dialog
            } catch {
                errorMessage = error.localizedDescription
                Logger.error("Import failed: \(error)", category: "settings")
            }
        }
    }

    /// Clear success message after delay
    private func clearSuccessMessage() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            successMessage = nil
        }
    }
}
