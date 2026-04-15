//
//  PreferencesService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// Service for managing user preferences
@MainActor
protocol PreferencesService: ObservableObject {
    /// Current preferences
    var preferences: AppPreferences { get }

    /// Update preferences
    /// - Parameter preferences: New preferences to save
    /// - Throws: If persistence fails
    func update(_ preferences: AppPreferences) throws

    /// Reset preferences to defaults
    func reset()
}
