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
    @StateObject private var coordinator: AppCoordinator

    init() {
        let repository = CoreDataTodoRepository(
            context: PersistenceController.shared.container.viewContext
        )

        let hotkeyService = CarbonHotkeyService()
        let pasteboardService = NSPasteboardService()
        let activeAppService = NSWorkspaceActiveApplicationService()

        let appCoordinator = AppCoordinator(
            repository: repository,
            hotkeyService: hotkeyService,
            pasteboardService: pasteboardService,
            activeAppService: activeAppService
        )

        _coordinator = StateObject(wrappedValue: appCoordinator)
    }

    var body: some Scene {
        WindowGroup {
            MainView(coordinator: coordinator)
                .task {
                    await runMigration()
                }
        }

        MenuBarExtra {
            coordinator.makeMenuBarView()
        } label: {
            Image(systemName: "checkmark.circle")
        }

        Settings {
            coordinator.makeSettingsView()
        }
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
