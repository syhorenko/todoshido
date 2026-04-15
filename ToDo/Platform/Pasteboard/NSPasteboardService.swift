//
//  NSPasteboardService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import AppKit

/// NSPasteboard implementation of PasteboardService
final class NSPasteboardService: PasteboardService {
    func readString() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
}
