//
//  WeekRange.swift
//  ToDo
//
//  Created by syh on 17/04/2026.
//

import Foundation

/// Represents a week with start and end dates
struct WeekRange: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date

    static func == (lhs: WeekRange, rhs: WeekRange) -> Bool {
        lhs.start == rhs.start && lhs.end == rhs.end
    }

    /// Display string for the week (e.g., "Apr 13 – Apr 19")
    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return "\(startStr) – \(endStr)"
    }

    /// Check if this week is the current week
    var isCurrentWeek: Bool {
        let now = Date()
        return now >= start && now <= end
    }

    /// Get the previous week
    func previousWeek() -> WeekRange {
        let calendar = Calendar.current
        let newStart = calendar.date(byAdding: .day, value: -7, to: start)!
        let newEnd = calendar.date(byAdding: .day, value: -7, to: end)!
        return WeekRange(start: newStart, end: newEnd)
    }

    /// Get the next week
    func nextWeek() -> WeekRange {
        let calendar = Calendar.current
        let newStart = calendar.date(byAdding: .day, value: 7, to: start)!
        let newEnd = calendar.date(byAdding: .day, value: 7, to: end)!
        return WeekRange(start: newStart, end: newEnd)
    }

    /// Create a WeekRange for the current week
    static func currentWeek() -> WeekRange {
        let calendar = Calendar.current
        let now = Date()

        // Get the start of the week (Sunday or Monday depending on locale)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)!.start
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        return WeekRange(start: weekStart, end: weekEnd)
    }
}
