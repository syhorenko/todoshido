//
//  Constants.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// App-wide constants
enum Constants {
    /// Duplicate detection window in seconds
    static let duplicateDetectionSeconds: TimeInterval = 10

    /// Maximum preview text length for todo items
    static let maxPreviewTextLength: Int = 500

    /// Sidebar width for navigation split view
    static let sidebarMinWidth: CGFloat = 180
    static let sidebarIdealWidth: CGFloat = 200
}
