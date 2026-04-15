//
//  TodoPriority.swift
//  ToDoshido
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import SwiftUI

/// Priority level for a todo item
enum TodoPriority: Int16, Codable, CaseIterable {
    case low = 0
    case normal = 1
    case high = 2
    case urgent = 3

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }

    var color: Color {
        switch self {
        case .low: return AppColors.priorityLow
        case .normal: return AppColors.priorityNormal
        case .high: return AppColors.priorityHigh
        case .urgent: return AppColors.priorityUrgent
        }
    }
}
