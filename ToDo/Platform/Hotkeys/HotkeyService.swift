//
//  HotkeyService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Protocol for registering and managing global hotkeys
protocol HotkeyService {
    /// Register a global hotkey with a handler
    /// - Parameters:
    ///   - configuration: Hotkey configuration (key code, modifiers, identifier)
    ///   - handler: Closure to call when hotkey is pressed
    /// - Throws: Error if registration fails
    func register(
        configuration: HotkeyConfiguration,
        handler: @escaping () -> Void
    ) throws

    /// Unregister a previously registered hotkey
    /// - Parameter identifier: Unique identifier of the hotkey to unregister
    func unregister(identifier: String)
}
