//
//  NSWorkspaceActiveApplicationService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import AppKit

/// NSWorkspace implementation of ActiveApplicationService
final class NSWorkspaceActiveApplicationService: ActiveApplicationService {
    func getFrontmostApplication() -> (name: String?, bundleID: String?) {
        let app = NSWorkspace.shared.frontmostApplication
        return (app?.localizedName, app?.bundleIdentifier)
    }
}
