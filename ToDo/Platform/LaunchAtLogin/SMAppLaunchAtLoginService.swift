//
//  SMAppLaunchAtLoginService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import ServiceManagement

/// SMAppService-based implementation (macOS 13+)
final class SMAppLaunchAtLoginService: LaunchAtLoginService {
    private let service = SMAppService.mainApp

    var isEnabled: Bool {
        service.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            if service.status == .enabled {
                Logger.debug("Launch at login already enabled", category: "launch")
                return
            }
            try service.register()
            Logger.info("Launch at login enabled", category: "launch")
        } else {
            if service.status == .notRegistered {
                Logger.debug("Launch at login already disabled", category: "launch")
                return
            }
            try service.unregister()
            Logger.info("Launch at login disabled", category: "launch")
        }
    }
}
