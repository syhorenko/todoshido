//
//  CaptureTodoFromBrowserUseCase.swift
//  ToDo
//
//  Created by syh on 21/04/2026.
//

import Foundation

/// Use case for capturing todos from browser with URL extraction
@MainActor
final class CaptureTodoFromBrowserUseCase {
    private let browserURLService: BrowserURLService
    private let pasteboardService: PasteboardService
    private let activeAppService: ActiveApplicationService
    private let createUseCase: CreateTodoUseCase
    private let preferencesService: PreferencesService

    // Duplicate detection cache
    private var recentCaptures: [String: Date] = [:]

    init(
        browserURLService: BrowserURLService,
        pasteboardService: PasteboardService,
        activeAppService: ActiveApplicationService,
        createUseCase: CreateTodoUseCase,
        preferencesService: PreferencesService
    ) {
        self.browserURLService = browserURLService
        self.pasteboardService = pasteboardService
        self.activeAppService = activeAppService
        self.createUseCase = createUseCase
        self.preferencesService = preferencesService
    }

    enum CaptureError: Error {
        case noBrowserURL
        case clipboardEmpty
        case duplicateCapture
    }

    /// Execute browser capture
    /// - Returns: Created TodoItem
    /// - Throws: CaptureError if no URL or clipboard data available
    func execute() async throws -> TodoItem {
        // 1. Try to extract browser URL
        if let (url, title) = browserURLService.getCurrentBrowserURL() {
            return try await captureBrowserURL(url: url, title: title)
        }

        // 2. Fallback to clipboard
        Logger.debug("No browser URL found, falling back to clipboard", category: "browser-capture")
        return try await captureFromClipboard()
    }

    // MARK: - Private Methods

    private func captureBrowserURL(url: String, title: String?) async throws -> TodoItem {
        // Get frontmost app info
        let (appName, bundleID) = activeAppService.getFrontmostApplication()

        // Build todo text: "Title - URL" or just "URL"
        let todoText: String
        if let title = title, !title.isEmpty {
            todoText = "\(title)\n\(url)"
        } else {
            todoText = url
        }

        // Check for duplicate
        let cacheKey = makeCacheKey(text: todoText, bundleID: bundleID)
        if isDuplicate(cacheKey: cacheKey) {
            Logger.debug("Duplicate browser capture ignored", category: "browser-capture")
            throw CaptureError.duplicateCapture
        }

        // Create todo
        let item = try await createUseCase.execute(
            text: todoText,
            captureMethod: .browserCapture,
            sourceAppName: appName,
            sourceBundleID: bundleID
        )

        // Update cache
        recentCaptures[cacheKey] = Date()
        cleanExpiredCache()

        Logger.info("Captured from browser: \(url.prefix(50))", category: "browser-capture")
        return item
    }

    private func captureFromClipboard() async throws -> TodoItem {
        // Read clipboard
        guard let text = pasteboardService.readString(),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Logger.debug("Clipboard empty on browser capture fallback", category: "browser-capture")
            throw CaptureError.clipboardEmpty
        }

        // Get frontmost app
        let (appName, bundleID) = activeAppService.getFrontmostApplication()

        // Check for duplicate
        let cacheKey = makeCacheKey(text: text, bundleID: bundleID)
        if isDuplicate(cacheKey: cacheKey) {
            Logger.debug("Duplicate clipboard capture ignored", category: "browser-capture")
            throw CaptureError.duplicateCapture
        }

        // Create todo
        let item = try await createUseCase.execute(
            text: text,
            captureMethod: .browserCapture,
            sourceAppName: appName,
            sourceBundleID: bundleID
        )

        // Update cache
        recentCaptures[cacheKey] = Date()
        cleanExpiredCache()

        Logger.info("Captured from clipboard fallback: \(text.prefix(50))", category: "browser-capture")
        return item
    }

    private func makeCacheKey(text: String, bundleID: String?) -> String {
        "\(text)|\(bundleID ?? "none")"
    }

    private func isDuplicate(cacheKey: String) -> Bool {
        guard let captureTime = recentCaptures[cacheKey] else {
            return false
        }
        let detectionWindow = preferencesService.preferences.duplicateDetectionWindow
        return Date().timeIntervalSince(captureTime) < detectionWindow
    }

    private func cleanExpiredCache() {
        let now = Date()
        let detectionWindow = preferencesService.preferences.duplicateDetectionWindow
        recentCaptures = recentCaptures.filter { _, date in
            now.timeIntervalSince(date) < detectionWindow
        }
    }
}

// MARK: - Error Descriptions

extension CaptureTodoFromBrowserUseCase.CaptureError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noBrowserURL:
            return "No browser URL found"
        case .clipboardEmpty:
            return "No browser URL and clipboard is empty"
        case .duplicateCapture:
            return "Duplicate capture detected"
        }
    }
}
