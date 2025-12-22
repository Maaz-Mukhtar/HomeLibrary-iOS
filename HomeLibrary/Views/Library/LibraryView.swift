//
//  LibraryView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]
    @Query private var locations: [PredefinedLocation]
    @Query private var tags: [UserTag]

    @State private var searchText = ""
    @State private var viewMode: ViewMode = .grid
    @State private var sortBy: SortOption = .dateAdded
    @State private var sortOrder: SortOrder = .descending
    @State private var filterState = FilterState()
    @State private var showFilters = false

    private var filteredBooks: [Book] {
        var result = books

        // Apply search query
        if !searchText.isEmpty {
            var tempFilter = filterState
            tempFilter.searchQuery = searchText
            result = result.filter { tempFilter.matches($0, locations: locations) }
        } else if filterState.hasActiveFilters {
            result = result.filter { filterState.matches($0, locations: locations) }
        }

        // Apply sorting
        result = sortBooks(result)

        return result
    }

    private var availableGenres: [String] {
        Set(books.compactMap { $0.genre }).sorted()
    }

    private var availableTags: [String] {
        Set(books.flatMap { $0.tagNames }).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search books...", text: $searchText)
                    .textFieldStyle(.plain)
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
            .padding(.horizontal)
            .padding(.top, 8)

            // Active Filters Bar
            if filterState.hasActiveFilters {
                ActiveFiltersBar(filterState: $filterState)
                    .padding(.top, 8)
            }

            // Content
            if filteredBooks.isEmpty {
                EmptyStateView(
                    icon: books.isEmpty ? "books.vertical" : "magnifyingglass",
                    title: books.isEmpty ? "No Books Yet" : "No Results",
                    message: books.isEmpty
                        ? "Add your first book to get started"
                        : "Try adjusting your search or filters"
                )
            } else {
                ScrollView {
                    switch viewMode {
                    case .grid:
                        BookGridView(books: filteredBooks)
                    case .list:
                        BookListView(books: filteredBooks)
                    }
                }
            }
        }
        .navigationTitle("My Library")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Picker("Sort By", selection: $sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Label(option.rawValue, systemImage: option.systemImage)
                                .tag(option)
                        }
                    }

                    Divider()

                    Button {
                        sortOrder.toggle()
                    } label: {
                        Label(
                            sortOrder == .ascending ? "Ascending" : "Descending",
                            systemImage: sortOrder.systemImage
                        )
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        withAnimation {
                            viewMode = viewMode == .grid ? .list : .grid
                        }
                    } label: {
                        Image(systemName: viewMode.toggleImage)
                    }

                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                    .overlay(alignment: .topTrailing) {
                        if filterState.activeFilterCount > 0 {
                            Text("\(filterState.activeFilterCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Color.primaryBlue)
                                .clipShape(Circle())
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(
                filterState: $filterState,
                availableGenres: availableGenres,
                availableLocations: locations,
                availableTags: availableTags
            )
        }
    }

    private func sortBooks(_ books: [Book]) -> [Book] {
        let sorted: [Book]

        switch sortBy {
        case .dateAdded:
            sorted = books.sorted { $0.dateAdded > $1.dateAdded }
        case .title:
            sorted = books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .author:
            sorted = books.sorted {
                ($0.authors.first ?? "").localizedCaseInsensitiveCompare($1.authors.first ?? "") == .orderedAscending
            }
        case .genre:
            sorted = books.sorted {
                ($0.genre ?? "").localizedCaseInsensitiveCompare($1.genre ?? "") == .orderedAscending
            }
        case .location:
            sorted = books.sorted {
                let loc1 = $0.location?.displayText(locations: locations) ?? ""
                let loc2 = $1.location?.displayText(locations: locations) ?? ""
                return loc1.localizedCaseInsensitiveCompare(loc2) == .orderedAscending
            }
        case .favorites:
            sorted = books.sorted { $0.isFavorite && !$1.isFavorite }
        }

        return sortOrder == .ascending ? sorted : sorted.reversed()
    }
}

// MARK: - Active Filters Bar

struct ActiveFiltersBar: View {
    @Binding var filterState: FilterState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(filterState.genres), id: \.self) { genre in
                    FilterChip(label: genre, color: .tagBlue) {
                        filterState.toggleGenre(genre)
                    }
                }

                ForEach(Array(filterState.tagNames), id: \.self) { tag in
                    FilterChip(label: tag, color: .tagGreen) {
                        filterState.toggleTag(tag)
                    }
                }

                if filterState.favoritesOnly {
                    FilterChip(label: "Favorites", color: .tagRed) {
                        filterState.favoritesOnly = false
                    }
                }

                if filterState.hasActiveFilters {
                    Button("Clear All") {
                        filterState.clear()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let label: String
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .cornerRadius(Constants.CornerRadius.small)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LibraryView()
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self, UserTag.self, AppSettings.self], inMemory: true)
}
