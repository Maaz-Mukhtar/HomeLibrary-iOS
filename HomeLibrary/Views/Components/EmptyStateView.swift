//
//  EmptyStateView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.xl)

            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button(action: action) {
                    Text(buttonTitle)
                        .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, Constants.Spacing.sm)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "books.vertical",
        title: "No Books Yet",
        message: "Add your first book to get started",
        buttonTitle: "Add Book"
    ) {
        print("Add book tapped")
    }
}
