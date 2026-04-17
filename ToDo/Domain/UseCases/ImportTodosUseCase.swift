//
//  ImportTodosUseCase.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Use case for importing todos from JSON file
@MainActor
final class ImportTodosUseCase {
    private let repository: TodoRepository
    private let fileHandlingService: FileHandlingService

    init(repository: TodoRepository, fileHandlingService: FileHandlingService) {
        self.repository = repository
        self.fileHandlingService = fileHandlingService
    }

    /// Execute import: show open panel → read JSON → create todos
    /// - Returns: Number of todos imported
    func execute() async throws -> Int {
        // 1. Show open panel
        guard let url = await fileHandlingService.showOpenPanel(
            allowedFileTypes: ["json"]
        ) else {
            throw FileHandlingError.userCancelled
        }

        // 2. Read file
        let jsonData = try fileHandlingService.readData(from: url)

        // 3. Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportData: TodoExport
        do {
            exportData = try decoder.decode(TodoExport.self, from: jsonData)
        } catch {
            throw ImportError.invalidFormat
        }

        // 4. Validate version
        guard exportData.version == 1 else {
            throw ImportError.unsupportedVersion(exportData.version)
        }

        guard !exportData.todos.isEmpty else {
            throw ImportError.emptyFile
        }

        // 5. Import todos (append mode - doesn't replace existing)
        for todo in exportData.todos {
            try await repository.createTodo(todo)
        }

        Logger.info("Imported \(exportData.todos.count) todos from \(url.path)", category: "import")
        return exportData.todos.count
    }

    enum ImportError: LocalizedError {
        case unsupportedVersion(Int)
        case emptyFile
        case invalidFormat

        var errorDescription: String? {
            switch self {
            case .unsupportedVersion(let version):
                return "Unsupported file version: \(version). Please update the app."
            case .emptyFile:
                return "The file contains no todos to import."
            case .invalidFormat:
                return "Invalid file format. Please select a valid Todoshido export file."
            }
        }
    }
}
