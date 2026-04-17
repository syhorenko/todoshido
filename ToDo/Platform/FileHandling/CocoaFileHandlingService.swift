//
//  CocoaFileHandlingService.swift
//  ToDo
//
//  Created by Claude on 17/04/2026.
//

import AppKit
import UniformTypeIdentifiers

/// File handling service using AppKit (NSSavePanel/NSOpenPanel)
@MainActor
final class CocoaFileHandlingService: FileHandlingService {
    func showSavePanel(suggestedFilename: String, allowedFileTypes: [String]) async -> URL? {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = suggestedFilename
        savePanel.allowedContentTypes = allowedFileTypes.compactMap { UTType(filenameExtension: $0) }
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false

        // Try to get a window from the app's windows
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.isKeyWindow }) ?? NSApp.windows.first(where: { $0.isVisible }) {
            let response = await savePanel.beginSheetModal(for: window)
            return response == .OK ? savePanel.url : nil
        } else {
            // Fallback to regular modal if no suitable window
            let response = savePanel.runModal()
            return response == .OK ? savePanel.url : nil
        }
    }

    func showOpenPanel(allowedFileTypes: [String]) async -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = allowedFileTypes.compactMap { UTType(filenameExtension: $0) }
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true

        // Try to get a window from the app's windows
        if let window = NSApp.windows.first(where: { $0.isVisible && $0.isKeyWindow }) ?? NSApp.windows.first(where: { $0.isVisible }) {
            let response = await openPanel.beginSheetModal(for: window)
            return response == .OK ? openPanel.url : nil
        } else {
            // Fallback to regular modal if no suitable window
            let response = openPanel.runModal()
            return response == .OK ? openPanel.url : nil
        }
    }

    func writeData(_ data: Data, to url: URL) throws {
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw FileHandlingError.writeError(error)
        }
    }

    func readData(from url: URL) throws -> Data {
        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileHandlingError.readError(error)
        }
    }
}
