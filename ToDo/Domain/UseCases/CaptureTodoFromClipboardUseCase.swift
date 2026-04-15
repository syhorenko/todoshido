//
//  CaptureTodoFromClipboardUseCase.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Use case for capturing todos from clipboard with duplicate detection
@MainActor
final class CaptureTodoFromClipboardUseCase {
    private let pasteboardService: PasteboardService
    private let activeAppService: ActiveApplicationService
    private let createUseCase: CreateTodoUseCase

    // Duplicate detection cache
    private var recentCaptures: [String: Date] = [:]
    private let detectionWindow: TimeInterval

    init(
        pasteboardService: PasteboardService,
        activeAppService: ActiveApplicationService,
        createUseCase: CreateTodoUseCase,
        detectionWindow: TimeInterval = Constants.duplicateDetectionSeconds
    ) {
        self.pasteboardService = pasteboardService
        self.activeAppService = activeAppService
        self.createUseCase = createUseCase
        self.detectionWindow = detectionWindow
    }

    enum CaptureError: Error {
        case clipboardEmpty
        case duplicateCapture
    }

    /// Execute clipboard capture
    /// - Returns: Created TodoItem
    /// - Throws: CaptureError if clipboard is empty or duplicate detected
    func execute() async throws -> TodoItem {
        // 1. Read clipboard
        guard let text = pasteboardService.readString(),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Logger.debug("Clipboard empty or whitespace only", category: "capture")
            throw CaptureError.clipboardEmpty
        }

        // 2. Get frontmost app
        let (appName, bundleID) = activeAppService.getFrontmostApplication()

        // 3. Check for duplicate
        let cacheKey = makeCacheKey(text: text, bundleID: bundleID)
        if isDuplicate(cacheKey: cacheKey) {
            Logger.debug("Duplicate capture ignored: \(text.prefix(50))", category: "capture")
            throw CaptureError.duplicateCapture
        }

        // 4. Create todo
        let item = try await createUseCase.execute(
            text: text,
            captureMethod: .clipboardShortcut,
            sourceAppName: appName,
            sourceBundleID: bundleID
        )

        // 5. Update cache
        recentCaptures[cacheKey] = Date()
        cleanExpiredCache()

        Logger.info("Captured todo from \(appName ?? "Unknown"): \(text.prefix(50))", category: "capture")
        return item
    }

    // MARK: - Private Methods

    private func makeCacheKey(text: String, bundleID: String?) -> String {
        "\(text)|\(bundleID ?? "none")"
    }

    private func isDuplicate(cacheKey: String) -> Bool {
        guard let captureTime = recentCaptures[cacheKey] else {
            return false
        }
        return Date().timeIntervalSince(captureTime) < detectionWindow
    }

    private func cleanExpiredCache() {
        let now = Date()
        recentCaptures = recentCaptures.filter { _, date in
            now.timeIntervalSince(date) < detectionWindow
        }
    }
}

// MARK: - Error Descriptions

extension CaptureTodoFromClipboardUseCase.CaptureError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .clipboardEmpty:
            return "Clipboard is empty"
        case .duplicateCapture:
            return "Duplicate capture detected"
        }
    }
}
