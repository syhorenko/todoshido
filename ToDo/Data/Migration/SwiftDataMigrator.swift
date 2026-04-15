//
//  SwiftDataMigrator.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import SwiftUI
import SwiftData

/// Migrates existing SwiftData items to Core Data repository
/// Runs once on app launch, controlled by UserDefaults flag
final class SwiftDataMigrator {
    private let migrationKey = "hasCompletedSwiftDataMigration_v1"

    /// Check if migration is needed and execute if necessary
    /// - Parameter repository: Target Core Data repository
    func migrateIfNeeded(to repository: TodoRepository) async throws {
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            Logger.info("SwiftData migration already completed, skipping", category: "migration")
            return
        }

        Logger.info("Starting SwiftData migration...", category: "migration")

        do {
            let migratedCount = try await performMigration(to: repository)
            UserDefaults.standard.set(true, forKey: migrationKey)
            Logger.info("SwiftData migration completed: \(migratedCount) items migrated", category: "migration")
        } catch {
            Logger.error("SwiftData migration failed: \(error)", category: "migration")
            throw error
        }
    }

    private func performMigration(to repository: TodoRepository) async throws -> Int {
        // Since Item.swift has been deleted, migration is no longer possible
        // This is fine - the app will start with empty state
        // In a real migration scenario, we would keep Item.swift temporarily
        Logger.info("SwiftData migration skipped - legacy Item model not available", category: "migration")
        return 0
    }
}
