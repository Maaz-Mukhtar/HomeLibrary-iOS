//
//  FilterState.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation

/// Represents the current filter state for the library
struct FilterState: Equatable {
    var genres: Set<String> = []
    var locationIds: Set<UUID> = []
    var tagNames: Set<String> = []
    var favoritesOnly: Bool = false
    var searchQuery: String = ""

    var hasActiveFilters: Bool {
        !genres.isEmpty || !locationIds.isEmpty || !tagNames.isEmpty || favoritesOnly
    }

    var activeFilterCount: Int {
        genres.count + locationIds.count + tagNames.count + (favoritesOnly ? 1 : 0)
    }

    var hasSearchQuery: Bool {
        !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    mutating func clear() {
        genres.removeAll()
        locationIds.removeAll()
        tagNames.removeAll()
        favoritesOnly = false
    }

    mutating func clearAll() {
        clear()
        searchQuery = ""
    }

    mutating func toggleGenre(_ genre: String) {
        if genres.contains(genre) {
            genres.remove(genre)
        } else {
            genres.insert(genre)
        }
    }

    mutating func toggleLocation(_ locationId: UUID) {
        if locationIds.contains(locationId) {
            locationIds.remove(locationId)
        } else {
            locationIds.insert(locationId)
        }
    }

    mutating func toggleTag(_ tagName: String) {
        if tagNames.contains(tagName) {
            tagNames.remove(tagName)
        } else {
            tagNames.insert(tagName)
        }
    }

    func matches(_ book: Book, locations: [PredefinedLocation]) -> Bool {
        // Search query
        if hasSearchQuery {
            let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesTitle = book.title.lowercased().contains(query)
            let matchesAuthor = book.authors.contains { $0.lowercased().contains(query) }
            let matchesNotes = book.notes?.lowercased().contains(query) ?? false
            let matchesTags = book.tagNames.contains { $0.lowercased().contains(query) }
            let matchesISBN = book.isbn?.contains(query) ?? false

            if !(matchesTitle || matchesAuthor || matchesNotes || matchesTags || matchesISBN) {
                return false
            }
        }

        // Genre filter
        if !genres.isEmpty {
            guard let genre = book.genre, genres.contains(genre) else {
                return false
            }
        }

        // Location filter
        if !locationIds.isEmpty {
            guard let location = book.location,
                  location.type == .predefined,
                  let predefinedId = location.predefinedId,
                  locationIds.contains(predefinedId) else {
                return false
            }
        }

        // Tag filter
        if !tagNames.isEmpty {
            let hasMatchingTag = tagNames.contains { book.tagNames.contains($0) }
            if !hasMatchingTag { return false }
        }

        // Favorites filter
        if favoritesOnly && !book.isFavorite {
            return false
        }

        return true
    }
}
