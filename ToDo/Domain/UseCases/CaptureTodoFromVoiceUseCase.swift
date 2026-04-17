//
//  CaptureTodoFromVoiceUseCase.swift
//  ToDo
//
//  Created by Claude on 17/04/2026.
//

import Foundation

/// Use case for capturing a todo from voice input
@MainActor
final class CaptureTodoFromVoiceUseCase {
    private let speechRecognitionService: SpeechRecognitionService
    private let createUseCase: CreateTodoUseCase
    private let preferencesService: any PreferencesService

    // Cache for duplicate detection
    private var recentCaptures: [String: Date] = [:]

    init(
        speechRecognitionService: SpeechRecognitionService,
        createUseCase: CreateTodoUseCase,
        preferencesService: any PreferencesService
    ) {
        self.speechRecognitionService = speechRecognitionService
        self.createUseCase = createUseCase
        self.preferencesService = preferencesService
    }

    /// Execute voice capture
    /// - Parameter onPartialResult: Callback for partial transcription updates
    /// - Returns: Created todo item
    func execute(onPartialResult: @escaping (String) -> Void) async throws -> TodoItem {
        // Request authorization
        let authorized = await speechRecognitionService.requestAuthorization()
        guard authorized else {
            throw CaptureError.notAuthorized
        }

        // Start recognition
        let text = try await speechRecognitionService.recognize(onPartialResult: onPartialResult)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CaptureError.noSpeechDetected
        }

        // Check for duplicate
        if isDuplicate(text) {
            Logger.debug("Duplicate voice capture suppressed: \(text)", category: "capture")
            throw CaptureError.duplicateCapture
        }

        // Create todo
        let item = try await createUseCase.execute(
            text: text,
            captureMethod: .voiceCapture
        )

        // Update cache
        recentCaptures[text] = Date()
        cleanupOldCaptures()

        Logger.info("Captured todo from voice: \(item.id)", category: "capture")
        return item
    }

    /// Stop current voice recognition
    func stop() {
        speechRecognitionService.stopRecognition()
    }

    // MARK: - Duplicate Detection

    private func isDuplicate(_ text: String) -> Bool {
        let prefs = preferencesService.preferences
        let windowSeconds = TimeInterval(prefs.duplicateDetectionWindow)

        guard let lastCaptureDate = recentCaptures[text] else {
            return false
        }

        let timeSinceLastCapture = Date().timeIntervalSince(lastCaptureDate)
        return timeSinceLastCapture < windowSeconds
    }

    private func cleanupOldCaptures() {
        let prefs = preferencesService.preferences
        let windowSeconds = TimeInterval(prefs.duplicateDetectionWindow)
        let cutoffDate = Date().addingTimeInterval(-windowSeconds)

        recentCaptures = recentCaptures.filter { $0.value > cutoffDate }
    }

    // MARK: - Errors

    enum CaptureError: LocalizedError {
        case notAuthorized
        case recognitionFailed
        case noSpeechDetected
        case duplicateCapture

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Microphone access not authorized. Please enable in System Settings."
            case .recognitionFailed:
                return "Speech recognition failed. Please try again."
            case .noSpeechDetected:
                return "No speech detected. Please speak clearly and try again."
            case .duplicateCapture:
                return nil // Silent - duplicate detection is intentional
            }
        }
    }
}
