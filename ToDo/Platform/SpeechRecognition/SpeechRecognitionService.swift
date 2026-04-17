//
//  SpeechRecognitionService.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Protocol for speech recognition services
protocol SpeechRecognitionService {
    /// Request authorization for speech recognition and microphone access
    func requestAuthorization() async -> Bool

    /// Start speech recognition and return recognized text
    /// - Parameter onPartialResult: Callback for partial transcription updates
    /// - Returns: Final recognized text
    func recognize(onPartialResult: @escaping (String) -> Void) async throws -> String

    /// Stop current recognition session
    func stopRecognition()
}

/// Errors that can occur during speech recognition
enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case recognitionFailed
    case audioEngineError
    case noSpeechDetected

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Microphone access not authorized. Please enable in System Settings."
        case .recognitionFailed:
            return "Speech recognition failed. Please try again."
        case .audioEngineError:
            return "Audio recording error. Please check your microphone."
        case .noSpeechDetected:
            return "No speech detected. Please speak clearly and try again."
        }
    }
}
