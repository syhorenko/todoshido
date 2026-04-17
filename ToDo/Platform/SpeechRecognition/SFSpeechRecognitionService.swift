//
//  SFSpeechRecognitionService.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Speech
import AVFoundation

/// Speech recognition service using Apple's Speech framework
@MainActor
final class SFSpeechRecognitionService: SpeechRecognitionService {
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
    }

    func requestAuthorization() async -> Bool {
        // Request speech recognition authorization
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard speechAuthorized else {
            return false
        }

        // Request microphone authorization
        let micAuthorized = await AVAudioApplication.requestRecordPermission()
        return micAuthorized
    }

    func recognize(onPartialResult: @escaping (String) -> Void) async throws -> String {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechRecognitionError.recognitionFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            do {
                // Note: macOS doesn't require AVAudioSession configuration like iOS
                // Audio engine handles recording setup automatically

                // Create recognition request
                let request = SFSpeechAudioBufferRecognitionRequest()
                request.shouldReportPartialResults = true
                self.recognitionRequest = request

                // Get audio input node
                let inputNode = audioEngine.inputNode
                let recordingFormat = inputNode.outputFormat(forBus: 0)

                // Install tap on input node
                inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    request.append(buffer)
                }

                // Start audio engine
                audioEngine.prepare()
                try audioEngine.start()

                var finalText: String?
                var lastSpeechTime = Date()
                var hasDetectedSpeech = false

                // Start recognition task
                recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                    if let result = result {
                        let transcription = result.bestTranscription.formattedString
                        hasDetectedSpeech = true
                        lastSpeechTime = Date()

                        // Send partial result
                        onPartialResult(transcription)

                        if result.isFinal {
                            finalText = transcription
                            self.cleanup()
                            continuation.resume(returning: transcription)
                        }
                    }

                    if error != nil {
                        self.cleanup()
                        continuation.resume(throwing: SpeechRecognitionError.recognitionFailed)
                    }
                }

                // Auto-stop after 2 seconds of silence
                Task {
                    while audioEngine.isRunning {
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                        let silenceDuration = Date().timeIntervalSince(lastSpeechTime)
                        if hasDetectedSpeech && silenceDuration > 2.0 {
                            self.stopRecognition()
                            if let text = finalText, !text.isEmpty {
                                continuation.resume(returning: text)
                            } else if hasDetectedSpeech {
                                // Speech was detected but final text not ready yet, wait a bit more
                                continue
                            } else {
                                continuation.resume(throwing: SpeechRecognitionError.noSpeechDetected)
                            }
                            break
                        }
                    }
                }

            } catch {
                cleanup()
                continuation.resume(throwing: SpeechRecognitionError.audioEngineError)
            }
        }
    }

    func stopRecognition() {
        cleanup()
    }

    private func cleanup() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        // Note: macOS doesn't require audio session cleanup
    }
}
