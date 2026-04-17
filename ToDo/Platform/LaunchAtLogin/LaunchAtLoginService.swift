//
//  LaunchAtLoginService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation

/// Service for managing launch at login functionality
protocol LaunchAtLoginService {
    /// Whether app is currently set to launch at login
    var isEnabled: Bool { get }

    /// Enable or disable launch at login
    /// - Parameter enabled: True to enable, false to disable
    /// - Throws: If system fails to register/unregister
    func setEnabled(_ enabled: Bool) throws
}
