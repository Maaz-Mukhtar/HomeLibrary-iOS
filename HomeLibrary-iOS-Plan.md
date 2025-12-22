# iOS Home Library App - Detailed Implementation Plan

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [Data Models](#data-models)
5. [View Architecture](#view-architecture)
6. [Services Layer](#services-layer)
7. [Implementation Phases](#implementation-phases)
8. [UI/UX Specifications](#uiux-specifications)
9. [API Integration](#api-integration)
10. [Reference Files](#reference-files)

---

## Project Overview

### Purpose
Build a native iOS application that replicates the functionality of the Home Library web application - a personal book management system that allows users to catalog, organize, and track their book collection.

### Goals
- Full feature parity with the React web application
- Native iOS experience using SwiftUI
- Offline-first architecture with local persistence
- Future-ready structure for Firebase cloud sync
- Leverage iOS-native capabilities (camera, Vision OCR, haptics)

### Target Platform
- **Minimum iOS Version:** iOS 17.0
- **Devices:** iPhone (primary), iPad (responsive)
- **Orientation:** Portrait (primary), Landscape (supported on iPad)

---

## Technology Stack

### Core Frameworks (Apple Native - No External Dependencies)

| Framework | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI framework |
| **SwiftData** | Persistence layer (iOS 17+ replacement for Core Data) |
| **AVFoundation** | Camera access and barcode scanning |
| **Vision** | OCR text recognition from images |
| **PhotosUI** | Photo library access and image picker |
| **Combine** | Reactive programming for async operations |

### Why SwiftData over Core Data?
- Modern Swift-native syntax with macros
- Automatic iCloud sync capability (for future)
- Better integration with SwiftUI via `@Query` and `@Model`
- Simpler relationship management
- Built-in support for Codable types

### Architecture Pattern
**MVVM (Model-View-ViewModel)** with Repository pattern for data access abstraction.

```
┌─────────────────────────────────────────────────────────┐
│                        Views                            │
│   (SwiftUI Views - UI Layer)                           │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                    ViewModels                           │
│   (State Management, Business Logic)                    │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│                   Repositories                          │
│   (Data Access Abstraction)                            │
└─────────────────────┬───────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────┐
│              SwiftData / Services                       │
│   (Persistence, API Calls, Camera, OCR)                │
└─────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
HomeLibrary/
│
├── HomeLibraryApp.swift                    # App entry point, ModelContainer setup
├── ContentView.swift                       # Root TabView navigation
│
├── Models/
│   ├── Book.swift                          # Main book model (@Model)
│   ├── PredefinedLocation.swift            # Saved location model (@Model)
│   ├── UserTag.swift                       # Custom tag model (@Model)
│   ├── AppSettings.swift                   # User preferences (@Model)
│   ├── BookLocation.swift                  # Location type enum (Codable)
│   ├── SortOption.swift                    # Sort options enum
│   ├── FilterState.swift                   # Filter state struct
│   └── SyncStatus.swift                    # Sync status enum (future Firebase)
│
├── Views/
│   ├── Library/
│   │   ├── LibraryView.swift               # Main library screen
│   │   ├── BookGridView.swift              # LazyVGrid book display
│   │   ├── BookListView.swift              # List book display
│   │   ├── BookCardView.swift              # Grid item component
│   │   ├── BookListItemView.swift          # List row component
│   │   ├── FilterSheet.swift               # Bottom sheet for filters
│   │   ├── SortMenuView.swift              # Sort options menu
│   │   └── ActiveFiltersBar.swift          # Active filter chips display
│   │
│   ├── AddBook/
│   │   ├── AddBookView.swift               # Entry method selection screen
│   │   ├── EntryMethodCard.swift           # Entry method option card
│   │   ├── ManualEntryView.swift           # Manual form wrapper
│   │   ├── BookFormView.swift              # Reusable book form
│   │   ├── BarcodeScannerView.swift        # Fullscreen barcode scanner
│   │   ├── CoverCaptureView.swift          # Cover photo capture
│   │   ├── IsbnCaptureView.swift           # ISBN photo capture
│   │   ├── ScanResultView.swift            # API lookup results display
│   │   └── DuplicateWarningSheet.swift     # Duplicate detection alert
│   │
│   ├── BookDetail/
│   │   ├── BookDetailView.swift            # Full book details screen
│   │   ├── EditBookView.swift              # Edit book form
│   │   ├── BookCoverView.swift             # Large cover display
│   │   ├── BookMetadataSection.swift       # Metadata display section
│   │   └── DeleteConfirmationSheet.swift   # Delete confirmation
│   │
│   ├── Search/
│   │   ├── SearchView.swift                # Dedicated search screen
│   │   └── SearchResultsView.swift         # Search results display
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift              # Main settings screen
│   │   ├── LocationsManagementView.swift   # Locations CRUD
│   │   ├── LocationRowView.swift           # Location list item
│   │   ├── AddLocationSheet.swift          # Add/edit location
│   │   ├── TagsManagementView.swift        # Tags CRUD
│   │   ├── TagRowView.swift                # Tag list item with color
│   │   ├── AddTagSheet.swift               # Add/edit tag with color picker
│   │   └── AboutView.swift                 # App info, version
│   │
│   └── Components/
│       ├── CoverImageView.swift            # Async cover image loader
│       ├── CoverImagePicker.swift          # Cover selection component
│       ├── TagChipView.swift               # Colored tag chip
│       ├── TagSelectionView.swift          # Multi-select tag picker
│       ├── GenrePickerView.swift           # Genre selection
│       ├── LocationPickerView.swift        # Location type selection
│       ├── FavoriteButton.swift            # Heart toggle button
│       ├── EmptyStateView.swift            # Empty collection placeholder
│       ├── LoadingOverlay.swift            # Loading indicator overlay
│       ├── ErrorBanner.swift               # Error message display
│       └── CameraPermissionView.swift      # Camera permission request
│
├── ViewModels/
│   ├── LibraryViewModel.swift              # Library state, sorting, filtering
│   ├── AddBookViewModel.swift              # Add book flow state
│   ├── BookDetailViewModel.swift           # Detail view operations
│   ├── SearchViewModel.swift               # Search state and logic
│   ├── SettingsViewModel.swift             # Settings state
│   ├── LocationsViewModel.swift            # Locations management
│   └── TagsViewModel.swift                 # Tags management
│
├── Services/
│   ├── BookAPIService.swift                # Google Books + Open Library
│   ├── BarcodeScannerService.swift         # AVFoundation barcode detection
│   ├── OCRService.swift                    # Vision text recognition
│   ├── CameraService.swift                 # Camera session management
│   ├── ImageService.swift                  # Image compression, caching
│   └── HapticService.swift                 # Haptic feedback manager
│
├── Repositories/
│   ├── BookRepository.swift                # Book CRUD operations
│   ├── LocationRepository.swift            # Location CRUD operations
│   ├── TagRepository.swift                 # Tag CRUD operations
│   ├── SettingsRepository.swift            # Settings operations
│   └── Protocols/
│       ├── BookRepositoryProtocol.swift    # Abstraction for future sync
│       └── SyncableRepository.swift        # Sync interface (future)
│
├── Extensions/
│   ├── Color+Theme.swift                   # App color palette
│   ├── Color+Hex.swift                     # Hex color conversion
│   ├── View+Modifiers.swift                # Custom view modifiers
│   ├── String+Validation.swift             # ISBN validation, etc.
│   ├── Date+Formatting.swift               # Date display formatting
│   └── UIImage+Compression.swift           # Image size optimization
│
├── Utilities/
│   ├── Constants.swift                     # Genre list, tag colors, etc.
│   ├── ISBNValidator.swift                 # ISBN-10/13 validation
│   ├── DuplicateChecker.swift              # Duplicate detection logic
│   └── BookInfoParser.swift                # OCR text parsing
│
└── Resources/
    ├── Assets.xcassets/
    │   ├── AppIcon.appiconset/             # App icons
    │   ├── Colors/                         # Named colors
    │   └── Images/                         # Placeholder images
    ├── Localizable.strings                 # Localization (future)
    └── Info.plist                          # App configuration
```

---

## Data Models

### Book Model (Primary Entity)

```swift
import Foundation
import SwiftData

@Model
final class Book {
    // MARK: - Identifiers
    @Attribute(.unique) var id: UUID

    // MARK: - Core Information
    var title: String
    var authors: [String]
    var genre: String?
    var isbn: String?

    // MARK: - Cover Image
    @Attribute(.externalStorage)
    var coverImageData: Data?           // Locally captured/selected image
    var coverImageURL: String?          // URL from API lookup

    // MARK: - Organization
    var locationData: Data?             // Encoded BookLocation
    var tagNames: [String]              // Tag references by name
    var notes: String?
    var isFavorite: Bool

    // MARK: - Metadata
    var dateAdded: Date
    var lastModified: Date
    var addedBy: String?                // Future: multi-user support

    // MARK: - Sync (Future Firebase)
    var syncStatus: String              // SyncStatus raw value
    var cloudId: String?                // Firebase document ID

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
```

### BookLocation (Codable Struct)

```swift
import Foundation

struct BookLocation: Codable, Equatable, Hashable {
    enum LocationType: String, Codable {
        case predefined
        case custom
    }

    let type: LocationType
    let predefinedId: UUID?
    let customText: String?

    // MARK: - Factory Methods
    static func predefined(id: UUID) -> BookLocation {
        BookLocation(type: .predefined, predefinedId: id, customText: nil)
    }

    static func custom(text: String) -> BookLocation {
        BookLocation(type: .custom, predefinedId: nil, customText: text)
    }

    // MARK: - Display
    func displayText(locations: [PredefinedLocation]) -> String {
        switch type {
        case .predefined:
            guard let id = predefinedId,
                  let location = locations.first(where: { $0.id == id }) else {
                return "Unknown Location"
            }
            return location.name
        case .custom:
            return customText ?? "Unknown Location"
        }
    }
}
```

### PredefinedLocation Model

```swift
import Foundation
import SwiftData

@Model
final class PredefinedLocation {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var syncStatus: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.syncStatus = SyncStatus.synced.rawValue
    }
}
```

### UserTag Model

```swift
import Foundation
import SwiftData
import SwiftUI

@Model
final class UserTag {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date
    var syncStatus: String

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    init(id: UUID = UUID(), name: String, colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.colorHex = colorHex ?? TagColors.nextColor()
        self.createdAt = Date()
        self.syncStatus = SyncStatus.synced.rawValue
    }
}
```

### AppSettings Model

```swift
import Foundation
import SwiftData

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

    init() {
        self.id = "app-settings"
        self.viewModeRaw = ViewMode.grid.rawValue
        self.sortByRaw = SortOption.dateAdded.rawValue
        self.sortOrderRaw = SortOrder.descending.rawValue
        self.storageModeRaw = "local"
    }
}

// MARK: - Supporting Enums

enum ViewMode: String, Codable {
    case grid
    case list
}

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

enum SortOrder: String, Codable {
    case ascending
    case descending

    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

enum SyncStatus: String, Codable {
    case synced
    case pendingUpload
    case pendingDelete
    case conflict
}
```

### FilterState

```swift
import Foundation

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

    mutating func clear() {
        genres.removeAll()
        locationIds.removeAll()
        tagNames.removeAll()
        favoritesOnly = false
        searchQuery = ""
    }

    func matches(_ book: Book, locations: [PredefinedLocation]) -> Bool {
        // Search query
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            let matchesTitle = book.title.lowercased().contains(query)
            let matchesAuthor = book.authors.contains { $0.lowercased().contains(query) }
            let matchesNotes = book.notes?.lowercased().contains(query) ?? false
            let matchesTags = book.tagNames.contains { $0.lowercased().contains(query) }

            if !(matchesTitle || matchesAuthor || matchesNotes || matchesTags) {
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
```

---

## View Architecture

### Navigation Structure

```
TabView
├── Tab 1: Library
│   └── NavigationStack
│       ├── LibraryView (root)
│       │   ├── .sheet → FilterSheet
│       │   └── .navigationDestination → BookDetailView
│       │       ├── .navigationDestination → EditBookView
│       │       └── .sheet → DeleteConfirmationSheet
│
├── Tab 2: Search
│   └── NavigationStack
│       └── SearchView (root)
│           └── .navigationDestination → BookDetailView
│
├── Tab 3: Add Book
│   └── NavigationStack
│       └── AddBookView (root)
│           ├── .navigationDestination → ManualEntryView
│           ├── .fullScreenCover → BarcodeScannerView
│           ├── .fullScreenCover → CoverCaptureView
│           ├── .fullScreenCover → IsbnCaptureView
│           └── .sheet → DuplicateWarningSheet
│
└── Tab 4: Settings
    └── NavigationStack
        └── SettingsView (root)
            ├── .navigationDestination → LocationsManagementView
            │   └── .sheet → AddLocationSheet
            ├── .navigationDestination → TagsManagementView
            │   └── .sheet → AddTagSheet
            └── .navigationDestination → AboutView
```

### Key View Implementations

#### LibraryView Structure
```swift
struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var showFilters = false

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $viewModel.searchQuery)

            // Active filters bar (if any)
            if viewModel.filterState.hasActiveFilters {
                ActiveFiltersBar(
                    filterState: viewModel.filterState,
                    onClear: viewModel.clearFilters
                )
            }

            // Content
            if viewModel.filteredBooks.isEmpty {
                EmptyStateView(type: .noBooks)
            } else {
                ScrollView {
                    switch viewModel.viewMode {
                    case .grid:
                        BookGridView(books: viewModel.filteredBooks)
                    case .list:
                        BookListView(books: viewModel.filteredBooks)
                    }
                }
            }
        }
        .navigationTitle("My Library")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SortMenuView(
                    sortBy: $viewModel.sortBy,
                    sortOrder: $viewModel.sortOrder
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        viewModel.toggleViewMode()
                    } label: {
                        Image(systemName: viewModel.viewMode == .grid
                            ? "list.bullet" : "square.grid.2x2")
                    }

                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .badge(viewModel.filterState.activeFilterCount)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(filterState: $viewModel.filterState)
        }
    }
}
```

#### AddBookView Entry Methods
```swift
struct AddBookView: View {
    @State private var selectedMethod: EntryMethod?

    enum EntryMethod: String, CaseIterable, Identifiable {
        case manual = "Manual Entry"
        case barcode = "Scan Barcode"
        case coverPhoto = "Photo Cover"
        case isbnPhoto = "Photo ISBN"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .manual: return "keyboard"
            case .barcode: return "barcode.viewfinder"
            case .coverPhoto: return "camera"
            case .isbnPhoto: return "number"
            }
        }

        var description: String {
            switch self {
            case .manual: return "Enter book details manually"
            case .barcode: return "Scan ISBN barcode"
            case .coverPhoto: return "Take photo of book cover"
            case .isbnPhoto: return "Take photo of ISBN number"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(EntryMethod.allCases) { method in
                    EntryMethodCard(method: method) {
                        selectedMethod = method
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Add Book")
        .navigationDestination(item: $selectedMethod) { method in
            switch method {
            case .manual:
                ManualEntryView()
            case .barcode:
                BarcodeScannerContainerView()
            case .coverPhoto:
                CoverCaptureContainerView()
            case .isbnPhoto:
                IsbnCaptureContainerView()
            }
        }
    }
}
```

---

## Services Layer

### BookAPIService

```swift
import Foundation

actor BookAPIService {
    // MARK: - Cache
    private var cache: [String: CachedResult] = [:]
    private let cacheDuration: TimeInterval = 3600 // 1 hour

    struct CachedResult {
        let result: BookLookupResult
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > 3600
        }
    }

    // MARK: - Result Type
    struct BookLookupResult {
        let title: String
        let authors: [String]
        let genre: String?
        let coverImageURL: String?
        let isbn: String?
        let description: String?
    }

    // MARK: - Public Methods

    func lookupByISBN(_ isbn: String) async throws -> BookLookupResult? {
        let cleanISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)

        // Check cache
        if let cached = cache[cleanISBN], !cached.isExpired {
            return cached.result
        }

        // Try Open Library first (better cover images)
        if let result = try await fetchFromOpenLibrary(isbn: cleanISBN) {
            cache[cleanISBN] = CachedResult(result: result, timestamp: Date())
            return result
        }

        // Fallback to Google Books
        if let result = try await fetchFromGoogleBooks(query: "isbn:\(cleanISBN)") {
            cache[cleanISBN] = CachedResult(result: result, timestamp: Date())
            return result
        }

        return nil
    }

    func searchBooks(title: String, author: String? = nil) async throws -> BookLookupResult? {
        var query = title
        if let author = author, !author.isEmpty {
            query += "+inauthor:\(author)"
        }

        return try await fetchFromGoogleBooks(query: query)
    }

    // MARK: - Private Methods

    private func fetchFromOpenLibrary(isbn: String) async throws -> BookLookupResult? {
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bookData = json["ISBN:\(isbn)"] as? [String: Any] else {
            return nil
        }

        let title = bookData["title"] as? String ?? ""
        let authors = (bookData["authors"] as? [[String: Any]])?.compactMap { $0["name"] as? String } ?? []
        let subjects = (bookData["subjects"] as? [[String: Any]])?.compactMap { $0["name"] as? String }
        let coverURL = (bookData["cover"] as? [String: Any])?["large"] as? String

        return BookLookupResult(
            title: title,
            authors: authors,
            genre: subjects?.first,
            coverImageURL: coverURL,
            isbn: isbn,
            description: nil
        )
    }

    private func fetchFromGoogleBooks(query: String) async throws -> BookLookupResult? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&maxResults=1"
        guard let url = URL(string: urlString) else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)

        struct GoogleBooksResponse: Decodable {
            let items: [GoogleBookItem]?
        }

        struct GoogleBookItem: Decodable {
            let volumeInfo: VolumeInfo
        }

        struct VolumeInfo: Decodable {
            let title: String?
            let authors: [String]?
            let categories: [String]?
            let imageLinks: ImageLinks?
            let industryIdentifiers: [IndustryIdentifier]?
            let description: String?
        }

        struct ImageLinks: Decodable {
            let thumbnail: String?
            let small: String?
            let medium: String?
            let large: String?
        }

        struct IndustryIdentifier: Decodable {
            let type: String
            let identifier: String
        }

        let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        guard let item = response.items?.first else { return nil }

        let volumeInfo = item.volumeInfo
        let coverURL = volumeInfo.imageLinks?.large
            ?? volumeInfo.imageLinks?.medium
            ?? volumeInfo.imageLinks?.small
            ?? volumeInfo.imageLinks?.thumbnail

        let isbn = volumeInfo.industryIdentifiers?.first { $0.type.contains("ISBN") }?.identifier

        return BookLookupResult(
            title: volumeInfo.title ?? "",
            authors: volumeInfo.authors ?? [],
            genre: volumeInfo.categories?.first,
            coverImageURL: coverURL?.replacingOccurrences(of: "http:", with: "https:"),
            isbn: isbn,
            description: volumeInfo.description
        )
    }
}
```

### OCRService

```swift
import Vision
import UIKit

actor OCRService {
    // MARK: - Result Types

    struct OCRResult {
        let fullText: String
        let lines: [String]
        let confidence: Float
    }

    struct ParsedBookInfo {
        let possibleTitle: String?
        let possibleAuthor: String?
        let possibleISBN: String?
        let rawText: String
    }

    // MARK: - Text Extraction

    func extractText(from image: UIImage) async throws -> OCRResult {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.noResults)
                    return
                }

                let lines = observations.compactMap { observation -> String? in
                    observation.topCandidates(1).first?.string
                }

                let fullText = lines.joined(separator: "\n")
                let avgConfidence = observations.isEmpty ? 0 :
                    observations.compactMap { $0.topCandidates(1).first?.confidence }
                        .reduce(0, +) / Float(observations.count)

                continuation.resume(returning: OCRResult(
                    fullText: fullText,
                    lines: lines,
                    confidence: avgConfidence
                ))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Book Info Parsing

    func parseBookInfo(from result: OCRResult) -> ParsedBookInfo {
        let lines = result.lines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var possibleTitle: String?
        var possibleAuthor: String?
        var possibleISBN: String?

        // Extract ISBN if present
        let isbnPattern = #"(?:ISBN[:\-\s]*)?(\d{10}|\d{13}|\d[\d\-]{11,16}\d)"#
        for line in lines {
            if let match = line.range(of: isbnPattern, options: .regularExpression) {
                let extracted = String(line[match])
                    .replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
                if extracted.count == 10 || extracted.count == 13 {
                    possibleISBN = extracted
                    break
                }
            }
        }

        // Look for author indicators
        let authorIndicators = ["by ", "written by ", "author:", "from the author of "]
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            for indicator in authorIndicators {
                if lowercased.contains(indicator) {
                    if let range = lowercased.range(of: indicator) {
                        possibleAuthor = String(line[range.upperBound...])
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    // Title is likely the line before
                    if index > 0 && possibleTitle == nil {
                        possibleTitle = lines[index - 1]
                    }
                    break
                }
            }
        }

        // If no title found, use the longest line (usually the title)
        if possibleTitle == nil {
            possibleTitle = lines.max(by: { $0.count < $1.count })
        }

        // If no author found, look for name patterns
        if possibleAuthor == nil {
            let namePattern = #"^[A-Z][a-z]+(?:\s+[A-Z]\.?)?\s+[A-Z][a-z]+$"#
            for line in lines where line != possibleTitle {
                if line.range(of: namePattern, options: .regularExpression) != nil {
                    possibleAuthor = line
                    break
                }
            }
        }

        return ParsedBookInfo(
            possibleTitle: possibleTitle,
            possibleAuthor: possibleAuthor,
            possibleISBN: possibleISBN,
            rawText: result.fullText
        )
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process the image"
        case .noResults: return "No text found in image"
        }
    }
}
```

### BarcodeScannerService

```swift
import AVFoundation
import UIKit

protocol BarcodeScannerDelegate: AnyObject {
    func didScanBarcode(_ barcode: String)
    func didFailWithError(_ error: Error)
}

class BarcodeScannerService: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scannedCode: String?
    @Published var error: Error?

    weak var delegate: BarcodeScannerDelegate?

    let captureSession = AVCaptureSession()
    private var hasScanned = false

    override init() {
        super.init()
    }

    func setupSession() throws {
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw ScannerError.noCamera
        }

        let input = try AVCaptureDeviceInput(device: device)

        guard captureSession.canAddInput(input) else {
            throw ScannerError.cannotAddInput
        }
        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(output) else {
            throw ScannerError.cannotAddOutput
        }
        captureSession.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [
            .ean13,
            .ean8,
            .upce,
            .code128
        ]
    }

    func startScanning() {
        guard !captureSession.isRunning else { return }
        hasScanned = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        isScanning = true
    }

    func stopScanning() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
        isScanning = false
    }

    private func validateISBN(_ code: String) -> Bool {
        let digits = code.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)
        return digits.count == 10 || digits.count == 13
    }
}

extension BarcodeScannerService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue,
              validateISBN(code) else {
            return
        }

        hasScanned = true
        stopScanning()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        scannedCode = code
        delegate?.didScanBarcode(code)
    }
}

enum ScannerError: LocalizedError {
    case noCamera
    case cannotAddInput
    case cannotAddOutput
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noCamera: return "No camera available"
        case .cannotAddInput: return "Cannot access camera input"
        case .cannotAddOutput: return "Cannot configure scanner output"
        case .permissionDenied: return "Camera permission denied"
        }
    }
}
```

---

## Implementation Phases

### Phase 1: Core Foundation (Days 1-5)

**Objectives:**
- Set up Xcode project with proper configuration
- Implement all SwiftData models
- Create basic navigation structure
- Implement manual book entry

**Tasks:**

1. **Project Setup**
   - Create new Xcode project: "HomeLibrary"
   - Select SwiftUI App lifecycle
   - Set deployment target: iOS 17.0
   - Configure bundle identifier
   - Add Info.plist permissions:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>Scan book barcodes and capture cover photos</string>
     <key>NSPhotoLibraryUsageDescription</key>
     <string>Select book cover images from your library</string>
     ```

2. **SwiftData Setup**
   ```swift
   // HomeLibraryApp.swift
   @main
   struct HomeLibraryApp: App {
       var body: some Scene {
           WindowGroup {
               ContentView()
           }
           .modelContainer(for: [
               Book.self,
               PredefinedLocation.self,
               UserTag.self,
               AppSettings.self
           ])
       }
   }
   ```

3. **Create All Models**
   - `Book.swift`
   - `PredefinedLocation.swift`
   - `UserTag.swift`
   - `AppSettings.swift`
   - `BookLocation.swift`
   - `SortOption.swift`
   - `FilterState.swift`

4. **Navigation Structure**
   - `ContentView.swift` with TabView
   - Empty placeholder views for each tab

5. **BookFormView Implementation**
   - Title field (required)
   - Authors field (comma-separated)
   - Genre picker (predefined list)
   - ISBN field with lookup button (placeholder)
   - Location picker (none/predefined/custom)
   - Notes text area
   - Tags multi-select
   - Favorite toggle
   - Cover image picker (placeholder)

6. **Repository Layer**
   - `BookRepository.swift` with CRUD operations
   - `SettingsRepository.swift`

**Deliverables:**
- Users can add books manually
- Books persist in SwiftData
- Basic 4-tab navigation works

---

### Phase 2: Library Display (Days 6-10)

**Objectives:**
- Display books in grid and list views
- Implement sorting functionality
- Create book detail view with edit/delete

**Tasks:**

1. **LibraryView**
   - Search bar at top
   - Grid/list view toggle in toolbar
   - Sort menu in toolbar
   - Empty state when no books

2. **BookGridView**
   ```swift
   let columns = [GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)]

   LazyVGrid(columns: columns, spacing: 16) {
       ForEach(books) { book in
           NavigationLink(value: book) {
               BookCardView(book: book)
           }
       }
   }
   ```

3. **BookCardView**
   - Cover image (2:3 aspect ratio)
   - Title (2 lines max)
   - Author
   - Genre badge
   - Favorite button overlay

4. **BookListView & BookListItemView**
   - Thumbnail cover (60x90)
   - Title, author, genre
   - Location display
   - Favorite indicator

5. **Sorting Implementation**
   - All 6 sort options
   - Ascending/descending toggle
   - Persist preference in AppSettings

6. **BookDetailView**
   - Large cover image
   - All metadata display
   - Tags with colors
   - Edit button → EditBookView
   - Delete with confirmation
   - Favorite toggle

7. **EditBookView**
   - Reuse BookFormView
   - Pre-populate with existing data
   - Update book on save

**Deliverables:**
- Full library display with grid/list views
- All sorting options work
- View, edit, delete books

---

### Phase 3: Search & Filtering (Days 11-14)

**Objectives:**
- Full-text search across books
- Multi-dimensional filtering
- Filter state management

**Tasks:**

1. **LibraryViewModel Filter Logic**
   ```swift
   @Published var filterState = FilterState()

   var filteredBooks: [Book] {
       let filtered = books.filter { filterState.matches($0, locations: locations) }
       return sortBooks(filtered)
   }
   ```

2. **FilterSheet**
   - Section: Genres (multi-select from available)
   - Section: Locations (multi-select predefined)
   - Section: Tags (multi-select)
   - Toggle: Favorites only
   - Clear all button

3. **ActiveFiltersBar**
   - Horizontal scroll of filter chips
   - Tap to remove individual filter
   - Clear all button

4. **SearchView (dedicated tab)**
   - Prominent search field
   - Real-time results
   - Recent searches (optional)

5. **Search Implementation**
   - Case-insensitive matching
   - Search title, authors, notes, tags
   - Debounce input (300ms)

**Deliverables:**
- Search works across all text fields
- All filter dimensions work
- Filters combinable

---

### Phase 4: Barcode Scanning (Days 15-20)

**Objectives:**
- Camera permission handling
- AVFoundation barcode scanning
- API integration for ISBN lookup

**Tasks:**

1. **CameraService**
   - Check permission status
   - Request permission with callback
   - Handle denied state gracefully

2. **BarcodeScannerService**
   - AVFoundation setup
   - Support EAN-13, EAN-8, UPC-E, Code-128
   - ISBN validation
   - Duplicate scan prevention

3. **BarcodeScannerView (UIViewControllerRepresentable)**
   - Fullscreen camera preview
   - Scanning guide overlay
   - Close button
   - Flash toggle

4. **BookAPIService**
   - Open Library API integration
   - Google Books API integration
   - Response caching (1 hour)
   - Error handling

5. **Scan Flow Integration**
   ```
   Scan → Validate ISBN → Show Loading → API Lookup
   → Success: Navigate to BookFormView (prefilled)
   → Failure: Show error, option for manual entry
   ```

6. **ScanResultView**
   - Display found book info
   - Edit before saving
   - "Not the right book?" option

**Deliverables:**
- Working barcode scanner
- API lookup integration
- Scan-to-form flow complete

---

### Phase 5: OCR Features (Days 21-26)

**Objectives:**
- Vision framework text recognition
- Cover photo to book info
- ISBN photo extraction

**Tasks:**

1. **OCRService**
   - VNRecognizeTextRequest implementation
   - Accurate recognition level
   - Language correction enabled

2. **BookInfoParser**
   - Title extraction (longest line heuristic)
   - Author detection (by indicators)
   - ISBN pattern matching
   - Noise filtering

3. **CoverCaptureView**
   - Camera preview
   - Capture button
   - Preview captured image
   - Retake option
   - Process button

4. **Cover OCR Flow**
   ```
   Capture → Preview → Process (show progress)
   → Extract text → Parse book info
   → Optional API lookup → BookFormView (prefilled)
   ```

5. **IsbnCaptureView**
   - Similar to cover capture
   - Focus guide for ISBN area
   - Extract ISBN number
   - Validate and lookup

6. **Progress Indication**
   - Loading overlay during OCR
   - Progress percentage if available

**Deliverables:**
- Cover photo OCR working
- ISBN photo OCR working
- Both integrated with API lookup

---

### Phase 6: Settings & Organization (Days 27-31)

**Objectives:**
- Locations management CRUD
- Tags management CRUD with colors
- App preferences

**Tasks:**

1. **SettingsView**
   - View mode preference (persisted)
   - Storage mode (local only, cloud disabled)
   - Locations management link
   - Tags management link
   - About section

2. **LocationsManagementView**
   - List of saved locations
   - Add button
   - Swipe to delete
   - Tap to edit

3. **AddLocationSheet**
   - Name text field
   - Save/Cancel buttons
   - Edit mode support

4. **TagsManagementView**
   - List with color indicators
   - Add button
   - Swipe to delete
   - Tap to edit

5. **AddTagSheet**
   - Name text field
   - Color picker (8 predefined colors)
   - Save/Cancel buttons

6. **Tag Colors**
   ```swift
   struct TagColors {
       static let colors = [
           "#3B82F6", // Blue
           "#10B981", // Green
           "#F59E0B", // Amber
           "#EF4444", // Red
           "#8B5CF6", // Purple
           "#EC4899", // Pink
           "#06B6D4", // Cyan
           "#F97316"  // Orange
       ]

       static func nextColor() -> String {
           // Rotate through colors
       }
   }
   ```

**Deliverables:**
- Complete locations CRUD
- Complete tags CRUD with colors
- Settings preferences work

---

### Phase 7: Polish & Duplicate Detection (Days 32-35)

**Objectives:**
- Prevent duplicate books
- UI/UX polish
- Error handling

**Tasks:**

1. **Duplicate Detection**
   ```swift
   func checkForDuplicates(title: String, authors: [String]) -> [Book] {
       let normalizedTitle = title.lowercased().trimmingCharacters(in: .whitespaces)
       let normalizedAuthors = Set(authors.map { $0.lowercased() })

       return books.filter { book in
           let bookTitle = book.title.lowercased()
           let bookAuthors = Set(book.authors.map { $0.lowercased() })

           return bookTitle == normalizedTitle &&
                  !bookAuthors.isDisjoint(with: normalizedAuthors)
       }
   }
   ```

2. **DuplicateWarningSheet**
   - Show existing book details
   - "Save Anyway" button
   - "View Existing" button
   - "Cancel" button

3. **Empty States**
   - No books in library
   - No search results
   - No filter matches

4. **Loading States**
   - API lookup loading
   - OCR processing
   - Image loading

5. **Haptic Feedback**
   - Success: Book saved, barcode scanned
   - Warning: Duplicate detected
   - Selection: Favorite toggle

6. **Image Handling**
   - Compression before storage (0.7 quality)
   - Async image loading
   - Placeholder for missing covers

7. **Error Handling**
   - Network errors
   - Camera errors
   - OCR failures
   - Graceful degradation

**Deliverables:**
- Duplicate detection working
- Polished user experience
- Comprehensive error handling

---

### Phase 8: Firebase Preparation (Days 36-38)

**Objectives:**
- Prepare codebase for cloud sync
- Document migration path

**Tasks:**

1. **Sync Status Implementation**
   - All models have syncStatus
   - Track pendingUpload, pendingDelete

2. **Repository Protocol Abstraction**
   ```swift
   protocol BookRepositoryProtocol {
       func fetchAll() async throws -> [Book]
       func save(_ book: Book) async throws
       func delete(_ book: Book) async throws
       // ...
   }

   class LocalBookRepository: BookRepositoryProtocol { }
   // Future: class FirebaseBookRepository: BookRepositoryProtocol { }
   ```

3. **Sync Service Interface**
   ```swift
   protocol SyncServiceProtocol {
       func sync() async throws
       var syncState: SyncState { get }
   }
   ```

4. **Documentation**
   - Firebase integration guide
   - Data migration steps
   - Conflict resolution strategy

**Deliverables:**
- Codebase ready for Firebase
- Clear upgrade path documented

---

## UI/UX Specifications

### Color Palette

```swift
extension Color {
    // Primary
    static let primary = Color(hex: "#3B82F6")         // Blue
    static let primaryLight = Color(hex: "#93C5FD")

    // Background
    static let background = Color(hex: "#F9FAFB")      // Light gray
    static let surface = Color.white

    // Text
    static let textPrimary = Color(hex: "#111827")
    static let textSecondary = Color(hex: "#6B7280")

    // Accents
    static let favorite = Color(hex: "#EF4444")        // Red heart
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")

    // Tag colors (pastel)
    static let tagColors = [
        Color(hex: "#DBEAFE"),  // Blue
        Color(hex: "#D1FAE5"),  // Green
        Color(hex: "#FEF3C7"),  // Amber
        Color(hex: "#FEE2E2"),  // Red
        Color(hex: "#EDE9FE"),  // Purple
        Color(hex: "#FCE7F3"),  // Pink
        Color(hex: "#CFFAFE"),  // Cyan
        Color(hex: "#FFEDD5")   // Orange
    ]
}
```

### Typography

```swift
extension Font {
    static let titleLarge = Font.system(size: 28, weight: .bold)
    static let titleMedium = Font.system(size: 22, weight: .semibold)
    static let titleSmall = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 16, weight: .regular)
    static let bodyMedium = Font.system(size: 14, weight: .regular)
    static let bodySmall = Font.system(size: 12, weight: .regular)
    static let caption = Font.system(size: 11, weight: .medium)
}
```

### Spacing & Sizing

```swift
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

enum CoverSize {
    static let gridWidth: CGFloat = 150
    static let gridHeight: CGFloat = 225  // 2:3 ratio
    static let listWidth: CGFloat = 60
    static let listHeight: CGFloat = 90
    static let detailWidth: CGFloat = 200
    static let detailHeight: CGFloat = 300
}
```

---

## API Integration

### Google Books API

**Endpoint:** `https://www.googleapis.com/books/v1/volumes`

**Query Parameters:**
- `q`: Search query (e.g., `isbn:9780123456789`)
- `maxResults`: Number of results (use 1 for ISBN lookup)

**Response Fields Used:**
- `volumeInfo.title`
- `volumeInfo.authors[]`
- `volumeInfo.categories[]`
- `volumeInfo.imageLinks.large/medium/small/thumbnail`
- `volumeInfo.industryIdentifiers[].identifier`
- `volumeInfo.description`

### Open Library API

**ISBN Lookup:** `https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data`

**Search:** `https://openlibrary.org/search.json?title={title}&author={author}`

**Cover Images:** `https://covers.openlibrary.org/b/id/{cover_id}-L.jpg`

**Response Fields Used:**
- `title`
- `authors[].name`
- `subjects[].name`
- `cover.large/medium/small`

### Lookup Strategy

```
1. Try Open Library first (better cover quality)
2. If no result, try Google Books
3. Cache successful results for 1 hour
4. Return nil if both fail
```

---

## Reference Files

These files from the web app should be referenced during implementation:

| Feature | Web App File | Purpose |
|---------|-------------|---------|
| Data Models | `src/types/index.ts` | TypeScript interfaces → Swift models |
| API Integration | `src/services/bookApi.ts` | API endpoints, caching, response parsing |
| OCR Parsing | `src/services/ocrService.ts` | Text parsing logic, author detection |
| Filter Logic | `src/hooks/useFilters.ts` | Filter state, application logic |
| Form Fields | `src/components/books/BookForm.tsx` | Field requirements, validation |
| Genre List | `src/utils/constants.ts` (or similar) | 22 predefined genres |
| Tag Colors | `src/hooks/useTags.ts` | 8 pastel tag colors |

---

## Predefined Genres (22)

```swift
let genres = [
    "Fiction",
    "Non-Fiction",
    "Mystery",
    "Science Fiction",
    "Fantasy",
    "Romance",
    "Thriller",
    "Horror",
    "Biography",
    "History",
    "Science",
    "Self-Help",
    "Business",
    "Children",
    "Young Adult",
    "Poetry",
    "Art",
    "Cooking",
    "Travel",
    "Religion",
    "Philosophy",
    "Other"
]
```

---

## Summary

This implementation plan provides a comprehensive roadmap for building a native iOS Home Library app with full feature parity to the web application. The architecture is designed to be:

- **Maintainable:** Clear separation of concerns with MVVM
- **Testable:** Repository abstraction enables unit testing
- **Extensible:** Protocol-based services for future Firebase integration
- **Performant:** SwiftData with proper indexing, image caching
- **Accessible:** Dynamic Type, VoiceOver support
- **Native:** Leverages iOS frameworks (Vision, AVFoundation) for best UX

The 8-phase implementation ensures incremental delivery with working features at each milestone.
