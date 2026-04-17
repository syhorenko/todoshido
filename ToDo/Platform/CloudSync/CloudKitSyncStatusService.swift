//
//  CloudKitSyncStatusService.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import CloudKit
import CoreData
import Combine

/// CloudKit-based sync status implementation
final class CloudKitSyncStatusService: CloudSyncStatusService {
    let monitor: CloudKitSyncMonitor

    init(monitor: CloudKitSyncMonitor) {
        self.monitor = monitor
    }

    var isEnabled: Bool {
        monitor.accountStatus == .available
    }

    var statusDescription: String {
        monitor.statusDescription
    }

    var statusPublisher: AnyPublisher<String, Never> {
        monitor.$accountStatus
            .combineLatest(monitor.$isSyncing, monitor.$lastSyncDate)
            .map { [weak monitor] _, _, _ in
                monitor?.statusDescription ?? "Unknown"
            }
            .eraseToAnyPublisher()
    }

    var isSyncing: Bool {
        monitor.isSyncing
    }
}

