//
//  BookFormDataTests.swift
//  HomeLibraryTests
//
//  Created by Claude Code
//

import XCTest
@testable import HomeLibrary

final class BookFormDataTests: XCTestCase {

    // MARK: - isValid Tests

    func testIsValid_EmptyTitle_ReturnsFalse() {
        var formData = BookFormData()
        formData.title = ""

        XCTAssertFalse(formData.isValid)
    }

    func testIsValid_WhitespaceOnlyTitle_ReturnsFalse() {
        var formData = BookFormData()
        formData.title = "   "

        XCTAssertFalse(formData.isValid)
    }

    func testIsValid_ValidTitle_ReturnsTrue() {
        var formData = BookFormData()
        formData.title = "The Great Gatsby"

        XCTAssertTrue(formData.isValid)
    }

    func testIsValid_TitleWithLeadingWhitespace_ReturnsTrue() {
        var formData = BookFormData()
        formData.title = "  Valid Title  "

        XCTAssertTrue(formData.isValid)
    }

    // MARK: - authorsArray Tests

    func testAuthorsArray_EmptyString_ReturnsEmptyArray() {
        var formData = BookFormData()
        formData.authors = ""

        XCTAssertTrue(formData.authorsArray.isEmpty)
    }

    func testAuthorsArray_SingleAuthor_ReturnsOneElement() {
        var formData = BookFormData()
        formData.authors = "J.K. Rowling"

        XCTAssertEqual(formData.authorsArray, ["J.K. Rowling"])
    }

    func testAuthorsArray_MultipleAuthors_ReturnsArray() {
        var formData = BookFormData()
        formData.authors = "Author One, Author Two, Author Three"

        XCTAssertEqual(formData.authorsArray, ["Author One", "Author Two", "Author Three"])
    }

    func testAuthorsArray_WithExtraSpaces_TrimsWhitespace() {
        var formData = BookFormData()
        formData.authors = "  Author One  ,  Author Two  "

        XCTAssertEqual(formData.authorsArray, ["Author One", "Author Two"])
    }

    func testAuthorsArray_WithEmptySegments_FiltersEmpty() {
        var formData = BookFormData()
        formData.authors = "Author One, , Author Two"

        XCTAssertEqual(formData.authorsArray, ["Author One", "Author Two"])
    }

    // MARK: - bookLocation Tests

    func testBookLocation_TypeNone_ReturnsNil() {
        var formData = BookFormData()
        formData.locationType = .none

        XCTAssertNil(formData.bookLocation)
    }

    func testBookLocation_TypePredefinedWithId_ReturnsPredefinedLocation() {
        var formData = BookFormData()
        formData.locationType = .predefined
        let locationId = UUID()
        formData.selectedLocationId = locationId

        let location = formData.bookLocation
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.type, .predefined)
        XCTAssertEqual(location?.predefinedId, locationId)
    }

    func testBookLocation_TypePredefinedWithoutId_ReturnsNil() {
        var formData = BookFormData()
        formData.locationType = .predefined
        formData.selectedLocationId = nil

        XCTAssertNil(formData.bookLocation)
    }

    func testBookLocation_TypeCustomWithText_ReturnsCustomLocation() {
        var formData = BookFormData()
        formData.locationType = .custom
        formData.customLocationText = "Living Room Shelf"

        let location = formData.bookLocation
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.type, .custom)
        XCTAssertEqual(location?.customText, "Living Room Shelf")
    }

    func testBookLocation_TypeCustomEmptyText_ReturnsNil() {
        var formData = BookFormData()
        formData.locationType = .custom
        formData.customLocationText = ""

        XCTAssertNil(formData.bookLocation)
    }

    // MARK: - Init from Book Tests

    func testInitFromBook_CopiesAllFields() {
        let book = Book(
            title: "Test Book",
            authors: ["Author One", "Author Two"],
            genre: "Fiction",
            isbn: "1234567890",
            notes: "Great book!",
            tagNames: ["Read", "Favorite"],
            isFavorite: true
        )

        let formData = BookFormData(from: book, locations: [])

        XCTAssertEqual(formData.title, "Test Book")
        XCTAssertEqual(formData.authors, "Author One, Author Two")
        XCTAssertEqual(formData.genre, "Fiction")
        XCTAssertEqual(formData.isbn, "1234567890")
        XCTAssertEqual(formData.notes, "Great book!")
        XCTAssertEqual(formData.selectedTags, ["Read", "Favorite"])
        XCTAssertTrue(formData.isFavorite)
    }

    func testInitFromBook_WithNilOptionals_SetsEmptyStrings() {
        let book = Book(
            title: "Test Book",
            authors: ["Author"]
        )

        let formData = BookFormData(from: book, locations: [])

        XCTAssertEqual(formData.genre, "")
        XCTAssertEqual(formData.isbn, "")
        XCTAssertEqual(formData.notes, "")
    }
}
