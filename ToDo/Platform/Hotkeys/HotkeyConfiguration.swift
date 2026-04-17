//
//  HotkeyConfiguration.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Carbon

/// Configuration for a global hotkey
struct HotkeyConfiguration {
    /// Carbon key code (e.g., 17 for 'T')
    let keyCode: UInt32

    /// Carbon modifier keys (e.g., cmdKey | shiftKey)
    let modifiers: UInt32

    /// Unique identifier for this hotkey
    let identifier: String

    /// Default capture shortcut: Cmd+Shift+T
    static let captureShortcut = HotkeyConfiguration(
        keyCode: 17,  // 'T' key
        modifiers: UInt32(cmdKey | shiftKey),
        identifier: "com.todoshido.capture"
    )
}
