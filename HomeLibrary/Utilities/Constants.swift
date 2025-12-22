//
//  Constants.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation

enum Constants {
    // MARK: - App Info

    static let appName = "Home Library"
    static let appVersion = "1.0.0"

    // MARK: - UI Sizing

    enum CoverSize {
        static let gridWidth: CGFloat = 150
        static let gridHeight: CGFloat = 225  // 2:3 ratio
        static let listWidth: CGFloat = 60
        static let listHeight: CGFloat = 90
        static let detailWidth: CGFloat = 200
        static let detailHeight: CGFloat = 300
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 10
        static let large: CGFloat = 16
    }

    // MARK: - API

    enum API {
        static let googleBooksBaseURL = "https://www.googleapis.com/books/v1/volumes"
        static let openLibraryBaseURL = "https://openlibrary.org/api/books"
        static let openLibrarySearchURL = "https://openlibrary.org/search.json"
        static let openLibraryCoversURL = "https://covers.openlibrary.org/b/id"
        static let cacheDuration: TimeInterval = 3600 // 1 hour
    }

    // MARK: - Validation

    enum Validation {
        static let maxTitleLength = 500
        static let maxNotesLength = 5000
        static let isbnLength10 = 10
        static let isbnLength13 = 13
    }
}
