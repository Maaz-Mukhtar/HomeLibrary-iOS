//
//  AppSettings.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation
import SwiftData

/// Appearance mode for the app
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

/// User preferences and app settings
@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var viewModeRaw: String
    var sortByRaw: String
    var sortOrderRaw: String
    var storageModeRaw: String
    var appearanceModeRaw: String = AppearanceMode.system.rawValue

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

    var appearanceMode: AppearanceMode {
        get { AppearanceMode(rawValue: appearanceModeRaw) ?? .system }
        set { appearanceModeRaw = newValue.rawValue }
    }

    init() {
        self.id = "app-settings"
        self.viewModeRaw = ViewMode.grid.rawValue
        self.sortByRaw = SortOption.dateAdded.rawValue
        self.sortOrderRaw = SortOrder.descending.rawValue
        self.storageModeRaw = StorageMode.local.rawValue
        self.appearanceModeRaw = AppearanceMode.system.rawValue
    }
}

extension AppSettings: Identifiable {}
