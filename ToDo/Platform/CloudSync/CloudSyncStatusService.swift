//
//  CloudSyncStatusService.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import Combine

/// Service for checking iCloud sync status
protocol CloudSyncStatusService {
    /// Whether iCloud sync is available and enabled
    var isEnabled: Bool { get }

    /// Account status description
    var statusDescription: String { get }

    /// Publisher for sync status changes
    var statusPublisher: AnyPublisher<String, Never> { get }

    /// Whether actively syncing
    var isSyncing: Bool { get }
}
