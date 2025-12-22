//
//  BookLocation.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation

/// Represents a book's location - either a predefined saved location or a custom text
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
