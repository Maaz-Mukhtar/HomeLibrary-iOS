//
//  UserTag.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import Foundation
import SwiftData
import SwiftUI

/// A custom user-created tag with a color
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

extension UserTag: Identifiable {}

// MARK: - Tag Colors

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

    static let pastelColors = [
        "#DBEAFE", // Blue
        "#D1FAE5", // Green
        "#FEF3C7", // Amber
        "#FEE2E2", // Red
        "#EDE9FE", // Purple
        "#FCE7F3", // Pink
        "#CFFAFE", // Cyan
        "#FFEDD5"  // Orange
    ]

    private static var colorIndex = 0

    static func nextColor() -> String {
        let color = colors[colorIndex % colors.count]
        colorIndex += 1
        return color
    }

    static func reset() {
        colorIndex = 0
    }
}
