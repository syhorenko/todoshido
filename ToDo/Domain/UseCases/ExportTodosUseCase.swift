//
//  ExportTodosUseCase.swift
//  ToDo
//
//  Created by Claude on 17/04/2026.
//

import Foundation

/// Use case for exporting todos to JSON file
@MainActor
final class ExportTodosUseCase {
    private let repository: TodoRepository
    private let fileHandlingService: FileHandlingService

    init(repository: TodoRepository, fileHandlingService: FileHandlingService) {
        self.repository = repository
        self.fileHandlingService = fileHandlingService
    }

    /// Execute export: fetch all todos → show save panel → write JSON
    func execute() async throws {
        // 1. Fetch all todos (open + archived)
        let openTodos = try await repository.fetchOpenTodos()
        let archivedTodos = try await repository.fetchArchivedTodos()
        let allTodos = openTodos + archivedTodos

        guard !allTodos.isEmpty else {
            throw ExportError.noTodosToExport
        }

        // 2. Create export DTO
        let exportData = TodoExport.create(from: allTodos)

        // 3. Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(exportData)

        // 4. Show save panel with default filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "Todoshido-Export-\(dateFormatter.string(from: Date())).json"

        guard let url = await fileHandlingService.showSavePanel(
            suggestedFilename: filename,
            allowedFileTypes: ["json"]
        ) else {
            throw FileHandlingError.userCancelled
        }

        // 5. Write to file
        try fileHandlingService.writeData(jsonData, to: url)

        Logger.info("Exported \(allTodos.count) todos to \(url.path)", category: "export")
    }

    enum ExportError: LocalizedError {
        case noTodosToExport

        var errorDescription: String? {
            "No todos to export. Create some todos first."
        }
    }
}
