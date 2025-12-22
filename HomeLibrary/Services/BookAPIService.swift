//
//  BookAPIService.swift
//  HomeLibrary
//
//  Created by Claude Code
//

import Foundation

/// Service for looking up book information from external APIs
actor BookAPIService {
    // MARK: - Cache

    private var cache: [String: CachedResult] = [:]
    private let cacheDuration: TimeInterval = 3600 // 1 hour

    private struct CachedResult {
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
        let coverImageData: Data?  // Pre-downloaded image for instant display
        let isbn: String?
        let description: String?
    }

    // MARK: - Errors

    enum APIError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case noResults
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .networkError(let error): return "Network error: \(error.localizedDescription)"
            case .noResults: return "No book found for this ISBN"
            case .invalidResponse: return "Invalid response from server"
            }
        }
    }

    // MARK: - Public Methods

    func lookupByISBN(_ isbn: String) async throws -> BookLookupResult {
        let cleanISBN = isbn.replacingOccurrences(of: "[^0-9X]", with: "", options: .regularExpression)

        // Check cache
        if let cached = cache[cleanISBN], !cached.isExpired {
            return cached.result
        }

        // Try Open Library first (often has better cover images)
        if let result = try? await fetchFromOpenLibrary(isbn: cleanISBN) {
            // Pre-download the cover image for instant display
            let resultWithImage = await downloadCoverImage(for: result)
            cache[cleanISBN] = CachedResult(result: resultWithImage, timestamp: Date())
            return resultWithImage
        }

        // Fallback to Google Books
        if let result = try? await fetchFromGoogleBooks(query: "isbn:\(cleanISBN)") {
            // Pre-download the cover image for instant display
            let resultWithImage = await downloadCoverImage(for: result)
            cache[cleanISBN] = CachedResult(result: resultWithImage, timestamp: Date())
            return resultWithImage
        }

        throw APIError.noResults
    }

    // MARK: - Image Download

    private func downloadCoverImage(for result: BookLookupResult) async -> BookLookupResult {
        guard let urlString = result.coverImageURL,
              let url = URL(string: urlString) else {
            return result
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return BookLookupResult(
                title: result.title,
                authors: result.authors,
                genre: result.genre,
                coverImageURL: result.coverImageURL,
                coverImageData: data,
                isbn: result.isbn,
                description: result.description
            )
        } catch {
            return result
        }
    }

    func searchBooks(title: String, author: String? = nil) async throws -> BookLookupResult {
        var query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        if let author = author, !author.isEmpty {
            let encodedAuthor = author.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? author
            query += "+inauthor:\(encodedAuthor)"
        }

        guard let result = try await fetchFromGoogleBooks(query: query) else {
            throw APIError.noResults
        }

        return result
    }

    // MARK: - Open Library API

    private func fetchFromOpenLibrary(isbn: String) async throws -> BookLookupResult? {
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bookData = json["ISBN:\(isbn)"] as? [String: Any] else {
            return nil
        }

        let title = bookData["title"] as? String ?? ""
        guard !title.isEmpty else { return nil }

        let authors = (bookData["authors"] as? [[String: Any]])?.compactMap { $0["name"] as? String } ?? []
        let subjects = (bookData["subjects"] as? [[String: Any]])?.compactMap { $0["name"] as? String }

        // Use Open Library's dedicated covers API for higher quality
        let highQualityCoverURL = "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg"

        return BookLookupResult(
            title: title,
            authors: authors,
            genre: mapToGenre(subjects?.first),
            coverImageURL: highQualityCoverURL,
            coverImageData: nil,
            isbn: isbn,
            description: nil
        )
    }

    // MARK: - Google Books API

    private func fetchFromGoogleBooks(query: String) async throws -> BookLookupResult? {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&maxResults=1"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

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
        guard let title = volumeInfo.title, !title.isEmpty else { return nil }

        var coverURL = volumeInfo.imageLinks?.large
            ?? volumeInfo.imageLinks?.medium
            ?? volumeInfo.imageLinks?.small
            ?? volumeInfo.imageLinks?.thumbnail

        // Enhance Google Books thumbnail to get higher resolution
        // Remove zoom=1 (thumbnail) and add zoom=0 (full size), also remove edge=curl
        if var url = coverURL {
            url = url.replacingOccurrences(of: "http:", with: "https:")
            url = url.replacingOccurrences(of: "zoom=1", with: "zoom=0")
            url = url.replacingOccurrences(of: "&edge=curl", with: "")
            coverURL = url
        }

        let isbn = volumeInfo.industryIdentifiers?.first { $0.type.contains("ISBN") }?.identifier

        return BookLookupResult(
            title: title,
            authors: volumeInfo.authors ?? [],
            genre: mapToGenre(volumeInfo.categories?.first),
            coverImageURL: coverURL,
            coverImageData: nil,
            isbn: isbn,
            description: volumeInfo.description
        )
    }

    // MARK: - Helpers

    private func mapToGenre(_ category: String?) -> String? {
        guard let category = category?.lowercased() else { return nil }

        // Map common categories to our predefined genres
        let genreMapping: [(keywords: [String], genre: String)] = [
            (["fiction"], "Fiction"),
            (["non-fiction", "nonfiction"], "Non-Fiction"),
            (["mystery", "detective", "crime"], "Mystery"),
            (["science fiction", "sci-fi", "scifi"], "Science Fiction"),
            (["fantasy"], "Fantasy"),
            (["romance"], "Romance"),
            (["thriller", "suspense"], "Thriller"),
            (["horror"], "Horror"),
            (["biography", "autobiography", "memoir"], "Biography"),
            (["history", "historical"], "History"),
            (["science", "physics", "chemistry", "biology"], "Science"),
            (["self-help", "self help", "personal development"], "Self-Help"),
            (["business", "economics", "finance"], "Business"),
            (["children", "juvenile", "kids"], "Children"),
            (["young adult", "ya", "teen"], "Young Adult"),
            (["poetry", "poems"], "Poetry"),
            (["art", "photography"], "Art"),
            (["cooking", "cookbook", "food", "recipes"], "Cooking"),
            (["travel", "adventure"], "Travel"),
            (["religion", "spirituality", "faith"], "Religion"),
            (["philosophy"], "Philosophy")
        ]

        for (keywords, genre) in genreMapping {
            if keywords.contains(where: { category.contains($0) }) {
                return genre
            }
        }

        return "Other"
    }
}
