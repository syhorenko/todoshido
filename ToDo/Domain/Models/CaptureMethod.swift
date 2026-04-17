//
//  CaptureMethod.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Method used to capture a todo item
enum CaptureMethod: Int16, Codable {
    case clipboardShortcut
    case manualEntry
    case voiceCapture
    case shareExtension // future
    case accessibilitySelection // future
}
