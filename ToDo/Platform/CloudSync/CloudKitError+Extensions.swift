//
//  CloudKitError+Extensions.swift
//  ToDo
//
//  Created by syh on 15/04/2026.
//

import Foundation
import CloudKit

extension CKError {
    /// User-friendly error description
    var userFriendlyMessage: String {
        switch code {
        case .notAuthenticated:
            return "Please sign in to iCloud in System Settings"
        case .networkFailure, .networkUnavailable:
            return "Network connection unavailable. Sync will resume when online."
        case .quotaExceeded:
            return "iCloud storage is full. Free up space to continue syncing."
        case .zoneBusy, .serviceUnavailable:
            return "iCloud servers are busy. Sync will retry automatically."
        case .serverRejectedRequest:
            return "iCloud rejected the sync request. Please try again later."
        case .assetFileNotFound:
            return "Some data files are missing. Sync may be incomplete."
        case .partialFailure:
            return "Some items failed to sync. Sync will retry automatically."
        case .incompatibleVersion:
            return "App needs to be updated to continue syncing."
        default:
            return "Sync error: \(localizedDescription)"
        }
    }

    /// Whether error is user-actionable
    var requiresUserAction: Bool {
        switch code {
        case .notAuthenticated, .quotaExceeded, .incompatibleVersion:
            return true
        default:
            return false
        }
    }

    /// Whether error will retry automatically
    var willRetryAutomatically: Bool {
        switch code {
        case .networkFailure, .networkUnavailable, .zoneBusy, .serviceUnavailable, .partialFailure:
            return true
        default:
            return false
        }
    }
}
