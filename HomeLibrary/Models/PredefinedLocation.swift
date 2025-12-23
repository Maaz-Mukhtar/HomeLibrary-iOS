//
//  PredefinedLocation.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation
import SwiftData

/// A saved, reusable location for books (e.g., "Living Room - Shelf A")
@Model
final class PredefinedLocation {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date()
    var syncStatus: String = SyncStatus.synced.rawValue

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.syncStatus = SyncStatus.synced.rawValue
    }
}

extension PredefinedLocation: Identifiable {}
