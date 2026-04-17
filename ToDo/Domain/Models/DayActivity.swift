//
//  DayActivity.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Represents activity for a single day
struct DayActivity: Identifiable {
    let id = UUID()
    let date: Date
    let createdTodos: [TodoItem]
    let completedTodos: [TodoItem]

    /// Day name (e.g., "Monday")
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// Short day name (e.g., "Mon")
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Day of month (e.g., "15")
    var dayOfMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    /// Check if this day is today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Total activity count (created + completed)
    var totalActivity: Int {
        createdTodos.count + completedTodos.count
    }
}
