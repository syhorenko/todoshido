//
//  TodoStatus.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// Status of a todo item
enum TodoStatus: Int16, Codable {
    case active
    case done
    case archived
}
