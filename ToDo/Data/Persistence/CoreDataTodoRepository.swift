//
//  CoreDataTodoRepository.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import CoreData

/// Core Data implementation of TodoRepository
final class CoreDataTodoRepository: TodoRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchOpenTodos() async throws -> [TodoItem] {
        try await context.perform {
            let request = NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
            request.predicate = NSPredicate(format: "isArchived == NO")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedTodoItem.createdAt, ascending: false)]

            let managed = try self.context.fetch(request)
            return managed.map { $0.toDomain() }
        }
    }

    func fetchArchivedTodos() async throws -> [TodoItem] {
        try await context.perform {
            let request = NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
            request.predicate = NSPredicate(format: "isArchived == YES")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedTodoItem.completedAt, ascending: false)]

            let managed = try self.context.fetch(request)
            return managed.map { $0.toDomain() }
        }
    }

    func fetchAllTodos() async throws -> [TodoItem] {
        try await context.perform {
            let request = NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \ManagedTodoItem.createdAt, ascending: false)]

            let managed = try self.context.fetch(request)
            return managed.map { $0.toDomain() }
        }
    }

    func createTodo(_ item: TodoItem) async throws {
        try await context.perform {
            _ = ManagedTodoItem.create(from: item, in: self.context)
            try self.context.save()
            Logger.info("Created todo: \(item.id)", category: "repository")
        }
    }

    func updateTodo(_ item: TodoItem) async throws {
        try await context.perform {
            let request = NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
            request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
            request.fetchLimit = 1

            guard let managed = try self.context.fetch(request).first else {
                throw RepositoryError.itemNotFound(item.id)
            }

            managed.update(from: item)
            try self.context.save()
            Logger.info("Updated todo: \(item.id)", category: "repository")
        }
    }

    func deleteTodo(id: UUID) async throws {
        try await context.perform {
            let request = NSFetchRequest<ManagedTodoItem>(entityName: "ManagedTodoItem")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1

            guard let managed = try self.context.fetch(request).first else {
                throw RepositoryError.itemNotFound(id)
            }

            self.context.delete(managed)
            try self.context.save()
            Logger.info("Deleted todo: \(id)", category: "repository")
        }
    }
}

// MARK: - Errors

enum RepositoryError: Error {
    case itemNotFound(UUID)
}

extension RepositoryError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .itemNotFound(let id):
            return "Todo item with ID \(id) not found"
        }
    }
}
