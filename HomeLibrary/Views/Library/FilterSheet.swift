//
//  FilterSheet.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filterState: FilterState

    let availableGenres: [String]
    let availableLocations: [PredefinedLocation]
    let availableTags: [String]

    var body: some View {
        NavigationStack {
            List {
                // Favorites Section
                Section {
                    Toggle("Favorites Only", isOn: $filterState.favoritesOnly)
                }

                // Genres Section
                if !availableGenres.isEmpty {
                    Section("Genres") {
                        ForEach(availableGenres, id: \.self) { genre in
                            FilterRow(
                                label: genre,
                                isSelected: filterState.genres.contains(genre)
                            ) {
                                filterState.toggleGenre(genre)
                            }
                        }
                    }
                }

                // Locations Section
                if !availableLocations.isEmpty {
                    Section("Locations") {
                        ForEach(availableLocations) { location in
                            FilterRow(
                                label: location.name,
                                isSelected: filterState.locationIds.contains(location.id)
                            ) {
                                filterState.toggleLocation(location.id)
                            }
                        }
                    }
                }

                // Tags Section
                if !availableTags.isEmpty {
                    Section("Tags") {
                        ForEach(availableTags, id: \.self) { tag in
                            FilterRow(
                                label: tag,
                                isSelected: filterState.tagNames.contains(tag)
                            ) {
                                filterState.toggleTag(tag)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if filterState.hasActiveFilters {
                        Button("Clear All") {
                            filterState.clear()
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Filter Row

struct FilterRow: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FilterSheet(
        filterState: .constant(FilterState()),
        availableGenres: ["Fiction", "Non-Fiction", "Science Fiction"],
        availableLocations: [],
        availableTags: ["To Read", "Favorites", "Classics"]
    )
}
