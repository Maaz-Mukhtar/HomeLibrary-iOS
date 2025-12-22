//
//  ImageCacheServiceTests.swift
//  HomeLibraryTests
//
//  Created by Claude Code
//

import XCTest
import UIKit
@testable import HomeLibrary

final class ImageCacheServiceTests: XCTestCase {

    var cacheService: ImageCacheService!

    override func setUp() {
        super.setUp()
        cacheService = ImageCacheService.shared
        cacheService.clearCache()
    }

    override func tearDown() {
        cacheService.clearCache()
        super.tearDown()
    }

    // MARK: - Basic Cache Operations

    func testSetAndGetImage_Success() {
        let image = createTestImage(color: .red)
        let key = "test-image-1"

        cacheService.setImage(image, forKey: key)
        let retrievedImage = cacheService.image(forKey: key)

        XCTAssertNotNil(retrievedImage)
    }

    func testGetImage_NotInCache_ReturnsNil() {
        let result = cacheService.image(forKey: "non-existent-key")

        XCTAssertNil(result)
    }

    func testRemoveImage_RemovesFromCache() {
        let image = createTestImage(color: .blue)
        let key = "test-image-2"

        cacheService.setImage(image, forKey: key)
        XCTAssertNotNil(cacheService.image(forKey: key))

        cacheService.removeImage(forKey: key)
        XCTAssertNil(cacheService.image(forKey: key))
    }

    func testClearCache_RemovesAllImages() {
        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)

        cacheService.setImage(image1, forKey: "key1")
        cacheService.setImage(image2, forKey: "key2")

        cacheService.clearCache()

        XCTAssertNil(cacheService.image(forKey: "key1"))
        XCTAssertNil(cacheService.image(forKey: "key2"))
    }

    func testSetImage_OverwriteExisting_UpdatesCache() {
        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)
        let key = "test-key"

        cacheService.setImage(image1, forKey: key)
        cacheService.setImage(image2, forKey: key)

        let retrieved = cacheService.image(forKey: key)
        XCTAssertNotNil(retrieved)
    }

    func testMultipleKeys_IndependentStorage() {
        let image1 = createTestImage(color: .red)
        let image2 = createTestImage(color: .blue)

        cacheService.setImage(image1, forKey: "key1")
        cacheService.setImage(image2, forKey: "key2")

        XCTAssertNotNil(cacheService.image(forKey: "key1"))
        XCTAssertNotNil(cacheService.image(forKey: "key2"))

        cacheService.removeImage(forKey: "key1")

        XCTAssertNil(cacheService.image(forKey: "key1"))
        XCTAssertNotNil(cacheService.image(forKey: "key2"))
    }

    // MARK: - Helpers

    private func createTestImage(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
