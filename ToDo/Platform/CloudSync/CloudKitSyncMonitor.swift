//
//  CloudKitSyncMonitor.swift
//  ToDo
//
//  Created by Claude on 15/04/2026.
//

import Foundation
import CloudKit
import CoreData
import Combine

/// Monitors NSPersistentCloudKitContainer sync events
@MainActor
final class CloudKitSyncMonitor: ObservableObject {
    @Published private(set) var isSyncing: Bool = false
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var syncError: Error?
    @Published private(set) var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published private(set) var userActionableError: String?

    private let container: NSPersistentCloudKitContainer
    private var cancellables = Set<AnyCancellable>()

    init(container: NSPersistentCloudKitContainer) {
        self.container = container
        setupEventObserver()
        checkAccountStatus()
    }

    private func setupEventObserver() {
        // Observe CloudKit sync events
        NotificationCenter.default.publisher(
            for: NSPersistentCloudKitContainer.eventChangedNotification
        )
        .compactMap { $0.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event }
        .sink { [weak self] event in
            self?.handleSyncEvent(event)
        }
        .store(in: &cancellables)
    }

    private func handleSyncEvent(_ event: NSPersistentCloudKitContainer.Event) {
        switch event.type {
        case .setup:
            Logger.info("CloudKit setup event", category: "sync")

        case .import:
            if event.endDate == nil {
                isSyncing = true
            } else {
                isSyncing = false
                lastSyncDate = event.endDate
                Logger.info("CloudKit import completed", category: "sync")
            }

        case .export:
            if event.endDate == nil {
                isSyncing = true
            } else {
                isSyncing = false
                lastSyncDate = event.endDate
                Logger.info("CloudKit export completed", category: "sync")
            }

        @unknown default:
            Logger.debug("Unknown CloudKit event type", category: "sync")
        }

        if let error = event.error {
            syncError = error
            Logger.error("CloudKit sync error: \(error)", category: "sync")

            // Check if error requires user action
            if let ckError = error as? CKError, ckError.requiresUserAction {
                userActionableError = ckError.userFriendlyMessage
            }
        } else {
            syncError = nil
            userActionableError = nil
        }
    }

    private func checkAccountStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            Task { @MainActor in
                self?.accountStatus = status
                if let error = error {
                    Logger.error("CloudKit account status error: \(error)", category: "sync")
                }
            }
        }
    }

    var statusDescription: String {
        switch accountStatus {
        case .available:
            if isSyncing {
                return "Syncing..."
            } else if let lastSync = lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                return "Last synced \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            } else {
                return "iCloud Sync Enabled"
            }
        case .noAccount:
            return "Not signed in to iCloud"
        case .restricted:
            return "iCloud access restricted"
        case .couldNotDetermine:
            return "Checking iCloud status..."
        case .temporarilyUnavailable:
            return "iCloud temporarily unavailable"
        @unknown default:
            return "Unknown iCloud status"
        }
    }
}
