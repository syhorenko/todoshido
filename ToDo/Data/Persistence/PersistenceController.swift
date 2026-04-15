//
//  PersistenceController.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import CoreData

/// Manages Core Data stack with NSPersistentCloudKitContainer
/// CloudKit sync disabled for Milestone 1, can be enabled in future milestones
final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TodoDataModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Disable CloudKit sync for Milestone 1
        // This can be enabled in Milestone 4 by removing this line
        let description = container.persistentStoreDescriptions.first
        description?.cloudKitContainerOptions = nil

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // In production, handle this more gracefully
                // For now, crash so we catch issues during development
                fatalError("Core Data failed to load: \(error), \(error.userInfo)")
            }

            Logger.info("Core Data store loaded: \(storeDescription.url?.lastPathComponent ?? "unknown")", category: "persistence")
        }

        // Automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Use property-level merge policy to handle conflicts
        // Newer changes win when there's a conflict
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Preview instance for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        // Add sample data for previews
        let sampleItem = NSEntityDescription.insertNewObject(forEntityName: "ManagedTodoItem", into: viewContext)
        sampleItem.setValue(UUID(), forKey: "id")
        sampleItem.setValue("Sample todo from preview", forKey: "text")
        sampleItem.setValue(Date(), forKey: "createdAt")
        sampleItem.setValue(Date(), forKey: "updatedAt")
        sampleItem.setValue(0, forKey: "status") // active
        sampleItem.setValue(1, forKey: "captureMethod") // manualEntry
        sampleItem.setValue(false, forKey: "isArchived")

        do {
            try viewContext.save()
        } catch {
            Logger.error("Failed to save preview data: \(error)", category: "persistence")
        }

        return controller
    }()
}
