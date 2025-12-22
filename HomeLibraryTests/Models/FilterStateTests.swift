//
//  FilterStateTests.swift
//  HomeLibraryTests
//
//  Created by Claude Code
//

import XCTest
@testable import HomeLibrary

final class FilterStateTests: XCTestCase {

    // MARK: - Initial State Tests

    func testInitialState_IsEmpty() {
        let state = FilterState()

        XCTAssertTrue(state.genres.isEmpty)
        XCTAssertTrue(state.locationIds.isEmpty)
        XCTAssertTrue(state.tagNames.isEmpty)
        XCTAssertFalse(state.favoritesOnly)
        XCTAssertTrue(state.searchQuery.isEmpty)
    }

    // MARK: - hasActiveFilters Tests

    func testHasActiveFilters_NoFilters_ReturnsFalse() {
        let state = FilterState()
        XCTAssertFalse(state.hasActiveFilters)
    }

    func testHasActiveFilters_WithGenre_ReturnsTrue() {
        var state = FilterState()
        state.genres.insert("Fiction")
        XCTAssertTrue(state.hasActiveFilters)
    }

    func testHasActiveFilters_WithLocation_ReturnsTrue() {
        var state = FilterState()
        state.locationIds.insert(UUID())
        XCTAssertTrue(state.hasActiveFilters)
    }

    func testHasActiveFilters_WithTag_ReturnsTrue() {
        var state = FilterState()
        state.tagNames.insert("Read")
        XCTAssertTrue(state.hasActiveFilters)
    }

    func testHasActiveFilters_FavoritesOnly_ReturnsTrue() {
        var state = FilterState()
        state.favoritesOnly = true
        XCTAssertTrue(state.hasActiveFilters)
    }

    func testHasActiveFilters_SearchQueryOnly_ReturnsFalse() {
        var state = FilterState()
        state.searchQuery = "test"
        XCTAssertFalse(state.hasActiveFilters) // searchQuery is not counted as "active filter"
    }

    // MARK: - activeFilterCount Tests

    func testActiveFilterCount_NoFilters_ReturnsZero() {
        let state = FilterState()
        XCTAssertEqual(state.activeFilterCount, 0)
    }

    func testActiveFilterCount_MultipleFilters_ReturnsCorrectCount() {
        var state = FilterState()
        state.genres.insert("Fiction")
        state.genres.insert("Mystery")
        state.tagNames.insert("Read")
        state.favoritesOnly = true

        XCTAssertEqual(state.activeFilterCount, 4) // 2 genres + 1 tag + 1 favorite
    }

    // MARK: - hasSearchQuery Tests

    func testHasSearchQuery_Empty_ReturnsFalse() {
        let state = FilterState()
        XCTAssertFalse(state.hasSearchQuery)
    }

    func testHasSearchQuery_WhitespaceOnly_ReturnsFalse() {
        var state = FilterState()
        state.searchQuery = "   "
        XCTAssertFalse(state.hasSearchQuery)
    }

    func testHasSearchQuery_WithText_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "Harry Potter"
        XCTAssertTrue(state.hasSearchQuery)
    }

    // MARK: - Toggle Tests

    func testToggleGenre_Adds_ThenRemoves() {
        var state = FilterState()

        state.toggleGenre("Fiction")
        XCTAssertTrue(state.genres.contains("Fiction"))

        state.toggleGenre("Fiction")
        XCTAssertFalse(state.genres.contains("Fiction"))
    }

    func testToggleLocation_Adds_ThenRemoves() {
        var state = FilterState()
        let locationId = UUID()

        state.toggleLocation(locationId)
        XCTAssertTrue(state.locationIds.contains(locationId))

        state.toggleLocation(locationId)
        XCTAssertFalse(state.locationIds.contains(locationId))
    }

    func testToggleTag_Adds_ThenRemoves() {
        var state = FilterState()

        state.toggleTag("Read")
        XCTAssertTrue(state.tagNames.contains("Read"))

        state.toggleTag("Read")
        XCTAssertFalse(state.tagNames.contains("Read"))
    }

    // MARK: - Clear Tests

    func testClear_RemovesAllFiltersButKeepsSearchQuery() {
        var state = FilterState()
        state.genres.insert("Fiction")
        state.locationIds.insert(UUID())
        state.tagNames.insert("Read")
        state.favoritesOnly = true
        state.searchQuery = "test"

        state.clear()

        XCTAssertTrue(state.genres.isEmpty)
        XCTAssertTrue(state.locationIds.isEmpty)
        XCTAssertTrue(state.tagNames.isEmpty)
        XCTAssertFalse(state.favoritesOnly)
        XCTAssertEqual(state.searchQuery, "test") // searchQuery preserved
    }

    func testClearAll_RemovesEverything() {
        var state = FilterState()
        state.genres.insert("Fiction")
        state.searchQuery = "test"

        state.clearAll()

        XCTAssertTrue(state.genres.isEmpty)
        XCTAssertTrue(state.searchQuery.isEmpty)
    }

    // MARK: - Matches Tests

    func testMatches_NoFilters_ReturnsTrue() {
        let state = FilterState()
        let book = Book(title: "Test Book", authors: ["Author"])

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryMatchesTitle_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "Harry"
        let book = Book(title: "Harry Potter", authors: ["J.K. Rowling"])

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryMatchesAuthor_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "Rowling"
        let book = Book(title: "Harry Potter", authors: ["J.K. Rowling"])

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryNoMatch_ReturnsFalse() {
        var state = FilterState()
        state.searchQuery = "Tolkien"
        let book = Book(title: "Harry Potter", authors: ["J.K. Rowling"])

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryCaseInsensitive_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "HARRY"
        let book = Book(title: "Harry Potter", authors: ["J.K. Rowling"])

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_GenreFilterMatches_ReturnsTrue() {
        var state = FilterState()
        state.genres.insert("Fiction")
        let book = Book(title: "Test", authors: ["Author"], genre: "Fiction")

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_GenreFilterNoMatch_ReturnsFalse() {
        var state = FilterState()
        state.genres.insert("Fiction")
        let book = Book(title: "Test", authors: ["Author"], genre: "Mystery")

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_GenreFilterBookHasNoGenre_ReturnsFalse() {
        var state = FilterState()
        state.genres.insert("Fiction")
        let book = Book(title: "Test", authors: ["Author"])

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_FavoritesOnlyMatchesFavorite_ReturnsTrue() {
        var state = FilterState()
        state.favoritesOnly = true
        let book = Book(title: "Test", authors: ["Author"], isFavorite: true)

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_FavoritesOnlyNoMatch_ReturnsFalse() {
        var state = FilterState()
        state.favoritesOnly = true
        let book = Book(title: "Test", authors: ["Author"], isFavorite: false)

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_TagFilterMatches_ReturnsTrue() {
        var state = FilterState()
        state.tagNames.insert("Read")
        let book = Book(title: "Test", authors: ["Author"], tagNames: ["Read", "Favorite"])

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_TagFilterNoMatch_ReturnsFalse() {
        var state = FilterState()
        state.tagNames.insert("Read")
        let book = Book(title: "Test", authors: ["Author"], tagNames: ["ToRead"])

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_CombinedFiltersAllMatch_ReturnsTrue() {
        var state = FilterState()
        state.genres.insert("Fiction")
        state.favoritesOnly = true
        state.searchQuery = "Test"

        let book = Book(title: "Test Book", authors: ["Author"], genre: "Fiction", isFavorite: true)

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_CombinedFiltersOneNoMatch_ReturnsFalse() {
        var state = FilterState()
        state.genres.insert("Fiction")
        state.favoritesOnly = true

        let book = Book(title: "Test Book", authors: ["Author"], genre: "Fiction", isFavorite: false)

        XCTAssertFalse(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryMatchesISBN_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "978"
        let book = Book(title: "Test", authors: ["Author"], isbn: "9780141036144")

        XCTAssertTrue(state.matches(book, locations: []))
    }

    func testMatches_SearchQueryMatchesNotes_ReturnsTrue() {
        var state = FilterState()
        state.searchQuery = "great"
        let book = Book(title: "Test", authors: ["Author"], notes: "A great read!")

        XCTAssertTrue(state.matches(book, locations: []))
    }
}
