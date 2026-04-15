//
//  Logger.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import os.log

/// Simple logging wrapper
enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.todoshido.app"

    static func info(_ message: String, category: String = "general") {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .info, message)
    }

    static func error(_ message: String, category: String = "general") {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .error, message)
    }

    static func debug(_ message: String, category: String = "general") {
        os_log("%{public}@", log: OSLog(subsystem: subsystem, category: category), type: .debug, message)
    }
}
