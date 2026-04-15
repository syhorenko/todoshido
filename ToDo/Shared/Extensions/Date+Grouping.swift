//
//  Date+Grouping.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

extension Date {
    /// Returns the start of the day for this date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns true if this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Returns true if this date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    /// Returns a section title for grouping
    /// - Returns: "Today", "Yesterday", or formatted date string
    var sectionTitle: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: self)
        }
    }
}
