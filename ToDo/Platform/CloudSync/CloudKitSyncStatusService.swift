//
//  CloudKitSyncStatusService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation

/// CloudKit-based sync status implementation
/// Read-only placeholder for Milestone 4 (iCloud Sync)
final class CloudKitSyncStatusService: CloudSyncStatusService {

    init() {
        // Empty init - no CloudKit access until Milestone 4
    }

    var isEnabled: Bool {
        // Read from PersistenceController configuration
        // Currently CloudKit is in entitlements but sync disabled
        return false  // Will be true when Milestone 4 implemented
    }

    var statusDescription: String {
        if isEnabled {
            return "iCloud Sync Enabled"
        } else {
            return "iCloud Sync Disabled (Coming Soon)"
        }
    }
}
