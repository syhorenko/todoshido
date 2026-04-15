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

        if let description = container.persistentStoreDescriptions.first {
            if inMemory {
                description.url = URL(fileURLWithPath: "/dev/null")
            }

            // MILESTONE 4: CloudKit sync temporarily disabled
            // Enable history tracking (required for CloudKit sync)
            description.setOption(true as NSNumber,
                forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber,
                forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            // TEMPORARY: Disable CloudKit sync until container configured in Developer Portal
            // To enable: create "iCloud.com.syh.ToDoshido" container at:
            // https://developer.apple.com/account/resources/cloudcontainers/list
            description.cloudKitContainerOptions = nil
        }

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
        sampleItem.setValue(1, forKey: "priority") // normal

        do {
            try viewContext.save()
        } catch {
            Logger.error("Failed to save preview data: \(error)", category: "persistence")
        }

        return controller
    }()
}
