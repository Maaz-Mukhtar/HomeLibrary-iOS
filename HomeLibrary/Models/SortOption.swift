//
//  SortOption.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation

/// Available sort options for the library
enum SortOption: String, Codable, CaseIterable, Identifiable {
    case dateAdded = "Date Added"
    case title = "Title"
    case author = "Author"
    case genre = "Genre"
    case location = "Location"
    case favorites = "Favorites"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .dateAdded: return "calendar"
        case .title: return "textformat"
        case .author: return "person"
        case .genre: return "tag"
        case .location: return "mappin"
        case .favorites: return "heart"
        }
    }
}

/// Sort order (ascending or descending)
enum SortOrder: String, Codable {
    case ascending
    case descending

    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }

    var systemImage: String {
        self == .ascending ? "arrow.up" : "arrow.down"
    }
}

/// View mode for library display
enum ViewMode: String, Codable {
    case grid
    case list

    var systemImage: String {
        self == .grid ? "square.grid.2x2" : "list.bullet"
    }

    var toggleImage: String {
        self == .grid ? "list.bullet" : "square.grid.2x2"
    }
}
