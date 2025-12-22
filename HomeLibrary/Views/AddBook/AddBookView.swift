//
//  AddBookView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI

struct AddBookView: View {
    @State private var showManualEntry = false

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Header
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)

                    Text("Add a Book")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Choose how you want to add your book")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, Constants.Spacing.xl)

                // Entry Method Cards
                VStack(spacing: Constants.Spacing.md) {
                    EntryMethodCard(
                        icon: "keyboard",
                        title: "Manual Entry",
                        description: "Enter book details yourself",
                        color: .blue
                    ) {
                        showManualEntry = true
                    }

                    EntryMethodCard(
                        icon: "barcode.viewfinder",
                        title: "Scan Barcode",
                        description: "Scan the ISBN barcode",
                        color: .green,
                        isDisabled: true,
                        disabledReason: "Coming in Phase 4"
                    ) {
                        // TODO: Implement in Phase 4
                    }

                    EntryMethodCard(
                        icon: "camera",
                        title: "Photo Cover",
                        description: "Take a photo of the book cover",
                        color: .orange,
                        isDisabled: true,
                        disabledReason: "Coming in Phase 5"
                    ) {
                        // TODO: Implement in Phase 5
                    }

                    EntryMethodCard(
                        icon: "number",
                        title: "Photo ISBN",
                        description: "Take a photo of the ISBN number",
                        color: .purple,
                        isDisabled: true,
                        disabledReason: "Coming in Phase 5"
                    ) {
                        // TODO: Implement in Phase 5
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, Constants.Spacing.xl)
        }
        .navigationTitle("Add Book")
        .navigationDestination(isPresented: $showManualEntry) {
            ManualEntryView()
        }
    }
}

// MARK: - Entry Method Card

struct EntryMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isDisabled: Bool = false
    var disabledReason: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isDisabled ? .secondary : color)
                    .frame(width: 44, height: 44)
                    .background(isDisabled ? Color(.systemGray5) : color.opacity(0.15))
                    .cornerRadius(Constants.CornerRadius.medium)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(isDisabled ? .secondary : .primary)

                    if isDisabled, let reason = disabledReason {
                        Text(reason)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(Constants.CornerRadius.large)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    NavigationStack {
        AddBookView()
    }
}
