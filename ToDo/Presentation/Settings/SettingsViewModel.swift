//
//  SettingsViewModel.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// View model for Settings screen
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var preferences: AppPreferences
    @Published var errorMessage: String?
    @Published var syncErrorMessage: String?

    let preferencesService: PreferencesService
    let launchAtLoginService: LaunchAtLoginService
    let cloudSyncStatusService: CloudSyncStatusService

    init(
        preferencesService: PreferencesService,
        launchAtLoginService: LaunchAtLoginService,
        cloudSyncStatusService: CloudSyncStatusService
    ) {
        self.preferencesService = preferencesService
        self.launchAtLoginService = launchAtLoginService
        self.cloudSyncStatusService = cloudSyncStatusService
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
}
