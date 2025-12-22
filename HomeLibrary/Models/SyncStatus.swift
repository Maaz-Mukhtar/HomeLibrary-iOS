//
//  SyncStatus.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation

/// Sync status for future Firebase integration
enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingDelete
    case conflict
}
