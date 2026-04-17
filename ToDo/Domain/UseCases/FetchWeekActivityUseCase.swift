//
//  FetchWeekActivityUseCase.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Use case for fetching week activity data
final class FetchWeekActivityUseCase {
    private let repository: TodoRepository

    init(repository: TodoRepository) {
        self.repository = repository
    }

    /// Fetch activity for each day in the given week
    /// - Parameter weekRange: The week to fetch activity for
    /// - Returns: Array of DayActivity for each day in the week
    func execute(for weekRange: WeekRange) async throws -> [DayActivity] {
        // Fetch all todos (both active and archived)
        let allTodos = try await repository.fetchAllTodos()

        var dayActivities: [DayActivity] = []
        let calendar = Calendar.current

        // Generate activity for each day in the week
        var currentDate = weekRange.start
        while currentDate <= weekRange.end {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            // Filter todos created on this day
            let createdTodos = allTodos.filter { todo in
                todo.createdAt >= startOfDay && todo.createdAt < endOfDay
            }

            // Filter todos completed on this day
            let completedTodos = allTodos.filter { todo in
                guard let completedAt = todo.completedAt else { return false }
                return completedAt >= startOfDay && completedAt < endOfDay
            }

            let dayActivity = DayActivity(
                date: startOfDay,
                createdTodos: createdTodos,
                completedTodos: completedTodos
            )
            dayActivities.append(dayActivity)

            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dayActivities
    }
}
