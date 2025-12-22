//
//  BookDetailView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var locations: [PredefinedLocation]
    @Query private var tags: [UserTag]

    @Bindable var book: Book

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.lg) {
                // Cover Image
                BookCoverImage(
                    imageData: book.coverImageData,
                    imageURL: book.coverImageURL
                )
                .frame(width: Constants.CoverSize.detailWidth, height: Constants.CoverSize.detailHeight)
                .cornerRadius(Constants.CornerRadius.large)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)

                // Title & Author
                VStack(spacing: Constants.Spacing.sm) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    if book.hasAuthors {
                        Text(book.authorsDisplay)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Favorite Button
                Button {
                    toggleFavorite()
                } label: {
                    Label(
                        book.isFavorite ? "Favorited" : "Add to Favorites",
                        systemImage: book.isFavorite ? "heart.fill" : "heart"
                    )
                    .foregroundStyle(book.isFavorite ? .white : .red)
                    .padding(.horizontal, Constants.Spacing.lg)
                    .padding(.vertical, Constants.Spacing.sm)
                    .background(book.isFavorite ? Color.red : Color.red.opacity(0.1))
                    .cornerRadius(Constants.CornerRadius.large)
                }

                // Metadata Section
                VStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    if let genre = book.genre {
                        MetadataRow(icon: "tag", label: "Genre", value: genre)
                    }

                    if let isbn = book.isbn {
                        MetadataRow(icon: "barcode", label: "ISBN", value: isbn)
                    }

                    if let location = book.location {
                        MetadataRow(
                            icon: "mappin",
                            label: "Location",
                            value: location.displayText(locations: locations)
                        )
                    }

                    MetadataRow(
                        icon: "calendar",
                        label: "Added",
                        value: book.dateAdded.formatted(date: .abbreviated, time: .omitted)
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(Constants.CornerRadius.large)
                .padding(.horizontal)

                // Tags
                if !book.tagNames.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text("Tags")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.sm) {
                                ForEach(book.tagNames, id: \.self) { tagName in
                                    TagChipView(
                                        name: tagName,
                                        color: tagColor(for: tagName)
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Notes
                if let notes = book.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                        Text("Notes")
                            .font(.headline)

                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(Constants.CornerRadius.large)
                    .padding(.horizontal)
                }

                Spacer(minLength: Constants.Spacing.xl)
            }
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationStack {
                EditBookView(book: book)
            }
        }
        .alert("Delete Book", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteBook()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(book.title)\"? This cannot be undone.")
        }
    }

    private func toggleFavorite() {
        book.isFavorite.toggle()
        book.lastModified = Date()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func deleteBook() {
        modelContext.delete(book)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    private func tagColor(for tagName: String) -> Color {
        if let tag = tags.first(where: { $0.name == tagName }) {
            return tag.color
        }
        return .blue
    }
}

// MARK: - Metadata Row

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Tag Chip View

struct TagChipView: View {
    let name: String
    let color: Color

    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .cornerRadius(Constants.CornerRadius.large)
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            book: Book(
                title: "The Great Gatsby",
                authors: ["F. Scott Fitzgerald"],
                genre: "Fiction",
                isbn: "9780743273565",
                notes: "A classic novel about the American Dream.",
                tagNames: ["Classic", "To Read"],
                isFavorite: true
            )
        )
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self, UserTag.self], inMemory: true)
}
