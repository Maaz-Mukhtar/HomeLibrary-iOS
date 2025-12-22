//
//  HomeLibraryUITests.swift
//  HomeLibraryUITests
//
//  Created by Claude Code
//

import XCTest

final class HomeLibraryUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch Tests

    func testAppLaunches_ShowsLibraryTab() throws {
        // Verify the app launches and shows the Library tab
        XCTAssertTrue(app.tabBars.buttons["Library"].exists)
    }

    func testTabBar_HasAllTabs() throws {
        XCTAssertTrue(app.tabBars.buttons["Library"].exists)
        XCTAssertTrue(app.tabBars.buttons["Search"].exists)
        XCTAssertTrue(app.tabBars.buttons["Add"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    // MARK: - Navigation Tests

    func testNavigateToAddBook_ShowsEntryMethods() throws {
        app.tabBars.buttons["Add"].tap()

        // Verify entry method options are shown
        XCTAssertTrue(app.staticTexts["Add a Book"].waitForExistence(timeout: 2))
    }

    func testNavigateToSettings_ShowsSettings() throws {
        app.tabBars.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
    }

    // MARK: - Add Book Flow Tests

    func testManualEntry_CanOpenForm() throws {
        app.tabBars.buttons["Add"].tap()

        // Tap on Manual Entry
        app.buttons["Manual Entry"].tap()

        // Verify form appears
        XCTAssertTrue(app.navigationBars["Add Book"].waitForExistence(timeout: 2))
    }
}
