//
//  PasteboardService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Protocol for reading clipboard/pasteboard content
protocol PasteboardService {
    /// Read string content from the system pasteboard
    /// - Returns: String content if available, nil otherwise
    func readString() -> String?
}
