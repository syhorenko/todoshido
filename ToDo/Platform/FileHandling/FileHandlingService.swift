//
//  FileHandlingService.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Protocol for file handling operations
protocol FileHandlingService {
    /// Show save panel and return selected URL
    /// - Parameters:
    ///   - suggestedFilename: Default filename to show
    ///   - allowedFileTypes: Array of file extensions (e.g., ["json", "txt"])
    /// - Returns: Selected URL or nil if cancelled
    func showSavePanel(
        suggestedFilename: String,
        allowedFileTypes: [String]
    ) async -> URL?

    /// Show open panel and return selected URL
    /// - Parameter allowedFileTypes: Array of file extensions to filter
    /// - Returns: Selected URL or nil if cancelled
    func showOpenPanel(
        allowedFileTypes: [String]
    ) async -> URL?

    /// Write data to file
    /// - Parameters:
    ///   - data: Data to write
    ///   - url: Destination URL
    func writeData(_ data: Data, to url: URL) throws

    /// Read data from file
    /// - Parameter url: Source URL
    /// - Returns: File contents as Data
    func readData(from url: URL) throws -> Data
}

/// Errors that can occur during file handling
enum FileHandlingError: LocalizedError {
    case userCancelled
    case writeError(Error)
    case readError(Error)

    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return nil // Silent - user action
        case .writeError(let error):
            return "Failed to write file: \(error.localizedDescription)"
        case .readError(let error):
            return "Failed to read file: \(error.localizedDescription)"
        }
    }
}
