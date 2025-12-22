//
//  MockURLProtocol.swift
//  HomeLibraryTests
//
//  Created by Claude Code
//

import Foundation

/// A mock URL protocol for testing network requests
class MockURLProtocol: URLProtocol {
    /// Map of URL patterns to mock responses
    static var mockResponses: [String: (Data?, HTTPURLResponse?, Error?)] = [:]

    /// Handler for dynamic request handling
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let handler = MockURLProtocol.requestHandler {
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
            return
        }

        // Check for static mock responses
        if let url = request.url?.absoluteString,
           let (data, response, error) = MockURLProtocol.mockResponses[url] {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
            return
        }

        // No mock found, fail with error
        let error = NSError(domain: "MockURLProtocol", code: 404, userInfo: [NSLocalizedDescriptionKey: "No mock response configured"])
        client?.urlProtocol(self, didFailWithError: error)
    }

    override func stopLoading() {}

    /// Reset all mock responses
    static func reset() {
        mockResponses = [:]
        requestHandler = nil
    }
}

/// Helper to create a mock URLSession configuration
extension URLSessionConfiguration {
    static var mock: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }
}
