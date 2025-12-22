//
//  Color+Theme.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    static let primaryBlue = Color(hex: "#3B82F6")!
    static let primaryLight = Color(hex: "#93C5FD")!

    // MARK: - Background Colors

    static let backgroundLight = Color(hex: "#F9FAFB")!
    static let surface = Color.white

    // MARK: - Text Colors

    static let textPrimary = Color(hex: "#111827")!
    static let textSecondary = Color(hex: "#6B7280")!

    // MARK: - Accent Colors

    static let favorite = Color(hex: "#EF4444")!
    static let success = Color(hex: "#10B981")!
    static let warning = Color(hex: "#F59E0B")!
    static let error = Color(hex: "#EF4444")!

    // MARK: - Tag Colors (Pastel)

    static let tagBlue = Color(hex: "#DBEAFE")!
    static let tagGreen = Color(hex: "#D1FAE5")!
    static let tagAmber = Color(hex: "#FEF3C7")!
    static let tagRed = Color(hex: "#FEE2E2")!
    static let tagPurple = Color(hex: "#EDE9FE")!
    static let tagPink = Color(hex: "#FCE7F3")!
    static let tagCyan = Color(hex: "#CFFAFE")!
    static let tagOrange = Color(hex: "#FFEDD5")!

    static let tagColors: [Color] = [
        .tagBlue, .tagGreen, .tagAmber, .tagRed,
        .tagPurple, .tagPink, .tagCyan, .tagOrange
    ]
}
