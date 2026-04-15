//
//  ToDoApp.swift
//  ToDo
//
//  Created by Serhii Horenko | CM.com on 15/04/2026.
//

import SwiftUI

@main
struct ToDoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView(coordinator: makeCoordinator())
                .task {
                    await runMigration()
                }
        }
    }

    private func makeCoordinator() -> AppCoordinator {
        let repository = CoreDataTodoRepository(
            context: persistenceController.container.viewContext
        )

        let hotkeyService = CarbonHotkeyService()
        let pasteboardService = NSPasteboardService()
        let activeAppService = NSWorkspaceActiveApplicationService()

        return AppCoordinator(
            repository: repository,
            hotkeyService: hotkeyService,
            pasteboardService: pasteboardService,
            activeAppService: activeAppService
        )
    }

    private func runMigration() async {
        let migrator = SwiftDataMigrator()
        let repository = CoreDataTodoRepository(
            context: persistenceController.container.viewContext
        )

        do {
            try await migrator.migrateIfNeeded(to: repository)
        } catch {
            Logger.error("Migration failed: \(error)", category: "app")
            // Non-fatal - app continues with empty state
        }
    }
}
