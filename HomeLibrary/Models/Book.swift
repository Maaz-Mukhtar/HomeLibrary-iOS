//
//  Book.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation
import SwiftData
import SwiftUI

/// Main book model - represents a book in the user's library
@Model
final class Book {
    // MARK: - Identifiers

    @Attribute(.unique) var id: UUID = UUID()

    // MARK: - Core Information

    var title: String = ""
    var authors: [String] = []
    var genre: String?
    var isbn: String?

    // MARK: - Cover Image

    @Attribute(.externalStorage)
    var coverImageData: Data?
    var coverImageURL: String?

    // MARK: - Organization

    var locationData: Data?
    var tagNames: [String] = []
    var notes: String?
    var isFavorite: Bool = false

    // MARK: - Metadata

    var dateAdded: Date = Date()
    var lastModified: Date = Date()
    var addedBy: String?

    // MARK: - Sync (Future Firebase)

    var syncStatus: String = SyncStatus.synced.rawValue
    var cloudId: String?

    // MARK: - Computed Properties

    var location: BookLocation? {
        get {
            guard let data = locationData else { return nil }
            return try? JSONDecoder().decode(BookLocation.self, from: data)
        }
        set {
            locationData = try? JSONEncoder().encode(newValue)
        }
    }

    var authorsDisplay: String {
        authors.isEmpty ? "Unknown Author" : authors.joined(separator: ", ")
    }

    var hasAuthors: Bool {
        !authors.isEmpty && authors.first?.isEmpty == false
    }

    var coverImage: Image? {
        guard let data = coverImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        title: String,
        authors: [String] = [],
        genre: String? = nil,
        coverImageData: Data? = nil,
        coverImageURL: String? = nil,
        isbn: String? = nil,
        location: BookLocation? = nil,
        notes: String? = nil,
        tagNames: [String] = [],
        isFavorite: Bool = false,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.genre = genre
        self.coverImageData = coverImageData
        self.coverImageURL = coverImageURL
        self.isbn = isbn
        self.locationData = try? JSONEncoder().encode(location)
        self.notes = notes
        self.tagNames = tagNames
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
        self.lastModified = Date()
        self.syncStatus = SyncStatus.synced.rawValue
    }
}

extension Book: Identifiable {}

// MARK: - Predefined Genres

enum Genre: String, CaseIterable, Identifiable {
    case fiction = "Fiction"
    case nonFiction = "Non-Fiction"
    case mystery = "Mystery"
    case scienceFiction = "Science Fiction"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case thriller = "Thriller"
    case horror = "Horror"
    case biography = "Biography"
    case history = "History"
    case science = "Science"
    case selfHelp = "Self-Help"
    case business = "Business"
    case children = "Children"
    case youngAdult = "Young Adult"
    case poetry = "Poetry"
    case art = "Art"
    case cooking = "Cooking"
    case travel = "Travel"
    case religion = "Religion"
    case philosophy = "Philosophy"
    case other = "Other"

    var id: String { rawValue }
}
