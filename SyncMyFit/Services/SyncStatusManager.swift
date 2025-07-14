//
//  SyncStatusManager.swift
//  SyncMyFit
//
//  Created by Baranidharan Pasupathi on 2025-07-12.
//

import Foundation
import Combine

// MARK: - SyncStatusManager

/// Manages the sync status and last synced timestamp for display and UI feedback.
class SyncStatusManager: ObservableObject {
    
    // MARK: - Singleton
    
    /// Shared instance for global access.
    static let shared = SyncStatusManager()

    // MARK: - Published Properties
    
    /// The timestamp of the last successful sync.
    @Published var lastSynced: Date? = UserDefaults.standard.object(forKey: "last_sync_time") as? Date
    
    /// The result of the most recent sync operation.
    @Published var syncResult: SyncResult? = nil

    // MARK: - Sync Result Enum
    
    /// Enum representing the outcome of a sync operation.
    enum SyncResult {
        case success
        case failure
    }

    // MARK: - Public Methods
    
    /// Updates the sync result and stores the last sync time if successful.
    /// - Parameter success: A boolean indicating whether the sync succeeded.
    func updateSyncResult(success: Bool) {
        if success {
            let now = Date()
            lastSynced = now
            UserDefaults.standard.set(now, forKey: "last_sync_time")
            syncResult = .success
        } else {
            syncResult = .failure
        }

        // Automatically reset the sync result after a short delay for UI feedback purposes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.syncResult = nil
        }
    }
}
