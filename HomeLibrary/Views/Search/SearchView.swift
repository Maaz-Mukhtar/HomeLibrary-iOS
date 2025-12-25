//
//  SearchView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]
    @Query private var locations: [PredefinedLocation]

    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @FocusState private var isSearchFocused: Bool

    private var searchResults: [Book] {
        guard !debouncedSearchText.isEmpty else { return [] }

        let query = debouncedSearchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        return books.filter { book in
            book.title.lowercased().contains(query) ||
            book.authors.contains { $0.lowercased().contains(query) } ||
            (book.notes?.lowercased().contains(query) ?? false) ||
            book.tagNames.contains { $0.lowercased().contains(query) } ||
            (book.isbn?.contains(query) ?? false) ||
            (book.genre?.lowercased().contains(query) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search by title, author, ISBN...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .submitLabel(.search)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(Constants.CornerRadius.medium)
            .padding()

            // Results
            if searchText.isEmpty && debouncedSearchText.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "Search Your Library",
                    message: "Find books by title, author, ISBN, tags, or notes"
                )
                .onTapGesture {
                    isSearchFocused = false
                }
            } else if searchResults.isEmpty && !debouncedSearchText.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No Results",
                    message: "No books match \"\(debouncedSearchText)\""
                )
                .onTapGesture {
                    isSearchFocused = false
                }
            } else {
                List {
                    Section("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")") {
                        ForEach(searchResults) { book in
                            NavigationLink(value: book) {
                                SearchResultRow(book: book, locations: locations)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollDismissesKeyboard(.interactively)
                .navigationDestination(for: Book.self) { book in
                    BookDetailView(book: book)
                }
            }
        }
        .navigationTitle("Search")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isSearchFocused = false
                }
            }
        }
        .onAppear {
            isSearchFocused = true
        }
        .task(id: searchText) {
            // Debounce search input by 300ms
            do {
                try await Task.sleep(for: .milliseconds(300))
                debouncedSearchText = searchText
            } catch {
                // Task was cancelled (user typed again)
            }
        }
        .onChange(of: searchText) { _, newValue in
            // Clear results immediately when search is cleared
            if newValue.isEmpty {
                debouncedSearchText = ""
            }
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let book: Book
    let locations: [PredefinedLocation]

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            BookCoverImage(
                imageData: book.coverImageData,
                imageURL: book.coverImageURL
            )
            .frame(width: 50, height: 75)
            .cornerRadius(Constants.CornerRadius.small)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if book.hasAuthors {
                    Text(book.authorsDisplay)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let genre = book.genre {
                    Text(genre)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if book.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self], inMemory: true)
}
