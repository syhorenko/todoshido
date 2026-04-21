//
//  BrowserURLService.swift
//  ToDo
//
//  Created by syh on 21/04/2026.
//

import Foundation

/// Protocol for extracting the current URL from active browser
protocol BrowserURLService {
    /// Get the current URL from the frontmost browser window
    /// - Returns: URL and page title if available, nil if no browser is active or URL cannot be extracted
    func getCurrentBrowserURL() -> (url: String, title: String?)?
}
