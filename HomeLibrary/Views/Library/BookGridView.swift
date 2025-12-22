//
//  BookGridView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI

struct BookGridView: View {
    let books: [Book]

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: Constants.Spacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Constants.Spacing.md) {
            ForEach(books) { book in
                NavigationLink(value: book) {
                    BookCardView(book: book)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .navigationDestination(for: Book.self) { book in
            BookDetailView(book: book)
        }
    }
}

// MARK: - Book Card View

struct BookCardView: View {
    @Environment(\.modelContext) private var modelContext
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            // Cover Image
            ZStack(alignment: .topTrailing) {
                BookCoverImage(
                    imageData: book.coverImageData,
                    imageURL: book.coverImageURL
                )
                .frame(width: Constants.CoverSize.gridWidth, height: Constants.CoverSize.gridHeight)
                .cornerRadius(Constants.CornerRadius.medium)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Favorite Button
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: book.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(book.isFavorite ? .red : .white)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(8)
            }

            // Title
            Text(book.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundStyle(.primary)

            // Author
            if book.hasAuthors {
                Text(book.authorsDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            // Genre Badge
            if let genre = book.genre {
                Text(genre)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.tagBlue)
                    .cornerRadius(Constants.CornerRadius.small)
            }
        }
        .frame(width: Constants.CoverSize.gridWidth)
    }

    private func toggleFavorite() {
        book.isFavorite.toggle()
        book.lastModified = Date()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Book Cover Image

struct BookCoverImage: View {
    let imageData: Data?
    let imageURL: String?

    var body: some View {
        if let data = imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let urlString = imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    PlaceholderCover()
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    PlaceholderCover()
                @unknown default:
                    PlaceholderCover()
                }
            }
        } else {
            PlaceholderCover()
        }
    }
}

struct PlaceholderCover: View {
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "book.closed")
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
            }
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            BookGridView(books: [
                Book(title: "The Great Gatsby", authors: ["F. Scott Fitzgerald"], genre: "Fiction"),
                Book(title: "1984", authors: ["George Orwell"], genre: "Science Fiction"),
                Book(title: "To Kill a Mockingbird", authors: ["Harper Lee"], genre: "Fiction", isFavorite: true)
            ])
        }
    }
    .modelContainer(for: Book.self, inMemory: true)
}
