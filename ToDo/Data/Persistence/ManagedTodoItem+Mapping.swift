//
//  ManagedTodoItem+Mapping.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import CoreData

/// NSManagedObject subclass for ManagedTodoItem entity
@objc(ManagedTodoItem)
final class ManagedTodoItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var text: String
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var completedAt: Date?
    @NSManaged var status: Int16
    @NSManaged var captureMethod: Int16
    @NSManaged var sourceAppName: String?
    @NSManaged var sourceBundleID: String?
    @NSManaged var isArchived: Bool
    @NSManaged var priority: Int16
}

// MARK: - Domain Model Mapping

extension ManagedTodoItem {
    /// Convert Core Data entity to domain model
    func toDomain() -> TodoItem {
        TodoItem(
            id: id,
            text: text,
            createdAt: createdAt,
            updatedAt: updatedAt,
            completedAt: completedAt,
            status: TodoStatus(rawValue: status) ?? .active,
            sourceAppName: sourceAppName,
            sourceBundleID: sourceBundleID,
            captureMethod: CaptureMethod(rawValue: captureMethod) ?? .manualEntry,
            priority: TodoPriority(rawValue: priority) ?? .normal
        )
    }

    /// Update Core Data entity from domain model
    func update(from domain: TodoItem) {
        id = domain.id
        text = domain.text
        createdAt = domain.createdAt
        updatedAt = domain.updatedAt
        completedAt = domain.completedAt
        status = domain.status.rawValue
        captureMethod = domain.captureMethod.rawValue
        sourceAppName = domain.sourceAppName
        sourceBundleID = domain.sourceBundleID
        isArchived = domain.status == .archived
        priority = domain.priority.rawValue
    }

    /// Create new Core Data entity from domain model
    static func create(from domain: TodoItem, in context: NSManagedObjectContext) -> ManagedTodoItem {
        let managed = ManagedTodoItem(context: context)
        managed.update(from: domain)
        return managed
    }
}
