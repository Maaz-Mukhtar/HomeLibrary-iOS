//
//  AppSettings.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation
import SwiftData

/// User preferences and app settings
@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var viewModeRaw: String
    var sortByRaw: String
    var sortOrderRaw: String
    var storageModeRaw: String

    var viewMode: ViewMode {
        get { ViewMode(rawValue: viewModeRaw) ?? .grid }
        set { viewModeRaw = newValue.rawValue }
    }

    var sortBy: SortOption {
        get { SortOption(rawValue: sortByRaw) ?? .dateAdded }
        set { sortByRaw = newValue.rawValue }
    }

    var sortOrder: SortOrder {
        get { SortOrder(rawValue: sortOrderRaw) ?? .descending }
        set { sortOrderRaw = newValue.rawValue }
    }

    enum StorageMode: String, Codable {
        case local
        case cloud
    }

    var storageMode: StorageMode {
        get { StorageMode(rawValue: storageModeRaw) ?? .local }
        set { storageModeRaw = newValue.rawValue }
    }

    init() {
        self.id = "app-settings"
        self.viewModeRaw = ViewMode.grid.rawValue
        self.sortByRaw = SortOption.dateAdded.rawValue
        self.sortOrderRaw = SortOrder.descending.rawValue
        self.storageModeRaw = StorageMode.local.rawValue
    }
}

extension AppSettings: Identifiable {}
