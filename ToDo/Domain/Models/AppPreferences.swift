//
//  AppPreferences.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import Carbon

/// User preferences for the ToDo app
struct AppPreferences: Codable, Equatable {
    /// Hotkey key code (e.g., 17 for 'T')
    var hotkeyKeyCode: UInt32

    /// Hotkey modifier flags (e.g., cmdKey | shiftKey)
    var hotkeyModifiers: UInt32

    /// Duplicate detection window in seconds
    var duplicateDetectionWindow: TimeInterval

    /// Whether app should launch at login
    var launchAtLogin: Bool

    /// Default priority for new todos
    var defaultTodoPriority: TodoPriority

    /// Version for future migrations
    var version: Int

    static let `default` = AppPreferences(
        hotkeyKeyCode: 17,  // 'T'
        hotkeyModifiers: UInt32(cmdKey | shiftKey),
        duplicateDetectionWindow: 10.0,
        launchAtLogin: false,
        defaultTodoPriority: .normal,
        version: 2
    )
}
