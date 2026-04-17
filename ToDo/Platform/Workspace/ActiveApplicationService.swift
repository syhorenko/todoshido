//
//  ActiveApplicationService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Protocol for detecting the frontmost (active) application
protocol ActiveApplicationService {
    /// Get information about the currently active application
    /// - Returns: Tuple with app name and bundle ID (both optional)
    func getFrontmostApplication() -> (name: String?, bundleID: String?)
}
