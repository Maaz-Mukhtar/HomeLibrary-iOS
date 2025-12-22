//
//  BookListView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct BookListView: View {
    let books: [Book]
    @Query private var locations: [PredefinedLocation]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(books) { book in
                NavigationLink(value: book) {
                    BookListItemView(book: book, locations: locations)
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 76)
            }
        }
        .padding(.vertical, Constants.Spacing.sm)
        .navigationDestination(for: Book.self) { book in
            BookDetailView(book: book)
        }
    }
}

// MARK: - Book List Item View

struct BookListItemView: View {
    @Environment(\.modelContext) private var modelContext
    let book: Book
    let locations: [PredefinedLocation]

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            // Cover Thumbnail
            BookCoverImage(
                imageData: book.coverImageData,
                imageURL: book.coverImageURL
            )
            .frame(width: Constants.CoverSize.listWidth, height: Constants.CoverSize.listHeight)
            .cornerRadius(Constants.CornerRadius.small)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

            // Book Info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if book.hasAuthors {
                    Text(book.authorsDisplay)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: Constants.Spacing.sm) {
                    if let genre = book.genre {
                        Text(genre)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.tagBlue)
                            .cornerRadius(Constants.CornerRadius.small)
                    }

                    if let location = book.location {
                        HStack(spacing: 2) {
                            Image(systemName: "mappin")
                                .font(.caption2)
                            Text(location.displayText(locations: locations))
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Favorite Indicator
            if book.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, Constants.Spacing.sm)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            BookListView(books: [
                Book(title: "The Great Gatsby", authors: ["F. Scott Fitzgerald"], genre: "Fiction"),
                Book(title: "1984", authors: ["George Orwell"], genre: "Science Fiction"),
                Book(title: "To Kill a Mockingbird", authors: ["Harper Lee"], genre: "Fiction", isFavorite: true)
            ])
        }
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self], inMemory: true)
}
