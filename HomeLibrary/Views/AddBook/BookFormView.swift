//
//  BookFormView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import PhotosUI

// MARK: - Book Form Data

struct BookFormData: Identifiable, Hashable {
    var id = UUID()
    var title: String = ""
    var authors: String = ""
    var genre: String = ""
    var isbn: String = ""
    var notes: String = ""
    var isFavorite: Bool = false

    // Location
    var locationType: LocationType = .none
    var selectedLocationId: UUID?
    var customLocationText: String = ""

    // Tags
    var selectedTags: [String] = []

    // Cover Image
    var coverImageData: Data?
    var coverImageURL: String?

    enum LocationType: String, CaseIterable, Hashable {
        case none = "None"
        case predefined = "Saved Location"
        case custom = "Custom"
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var authorsArray: [String] {
        authors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var bookLocation: BookLocation? {
        switch locationType {
        case .none:
            return nil
        case .predefined:
            guard let id = selectedLocationId else { return nil }
            return .predefined(id: id)
        case .custom:
            guard !customLocationText.isEmpty else { return nil }
            return .custom(text: customLocationText)
        }
    }

    // Initialize from existing book for editing
    init() {}

    init(from book: Book, locations: [PredefinedLocation]) {
        self.title = book.title
        self.authors = book.authors.joined(separator: ", ")
        self.genre = book.genre ?? ""
        self.isbn = book.isbn ?? ""
        self.notes = book.notes ?? ""
        self.isFavorite = book.isFavorite
        self.selectedTags = book.tagNames
        self.coverImageData = book.coverImageData
        self.coverImageURL = book.coverImageURL

        if let location = book.location {
            switch location.type {
            case .predefined:
                self.locationType = .predefined
                self.selectedLocationId = location.predefinedId
            case .custom:
                self.locationType = .custom
                self.customLocationText = location.customText ?? ""
            }
        }
    }
}

// MARK: - Book Form View

struct BookFormView: View {
    @Binding var formData: BookFormData
    let locations: [PredefinedLocation]
    let tags: [UserTag]
    let isEditing: Bool

    @State private var showImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Form {
            // Cover Image Section
            Section {
                VStack(spacing: Constants.Spacing.md) {
                    if let data = formData.coverImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(Constants.CornerRadius.medium)
                    } else if let urlString = formData.coverImageURL,
                              let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(Constants.CornerRadius.medium)
                        } placeholder: {
                            coverPlaceholder
                        }
                    } else {
                        coverPlaceholder
                    }

                    HStack {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Choose Photo", systemImage: "photo")
                        }

                        if formData.coverImageData != nil || formData.coverImageURL != nil {
                            Button(role: .destructive) {
                                formData.coverImageData = nil
                                formData.coverImageURL = nil
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        // Compress image
                        if let uiImage = UIImage(data: data),
                           let compressed = uiImage.jpegData(compressionQuality: 0.7) {
                            formData.coverImageData = compressed
                        } else {
                            formData.coverImageData = data
                        }
                    }
                }
            }

            // Basic Info Section
            Section("Book Details") {
                TextField("Title *", text: $formData.title)

                TextField("Authors (comma separated)", text: $formData.authors)

                Picker("Genre", selection: $formData.genre) {
                    Text("None").tag("")
                    ForEach(Genre.allCases) { genre in
                        Text(genre.rawValue).tag(genre.rawValue)
                    }
                }

                TextField("ISBN", text: $formData.isbn)
                    .keyboardType(.numberPad)
            }

            // Location Section
            Section("Location") {
                Picker("Location Type", selection: $formData.locationType) {
                    ForEach(BookFormData.LocationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                if formData.locationType == .predefined {
                    if locations.isEmpty {
                        Text("No saved locations. Add them in Settings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Location", selection: $formData.selectedLocationId) {
                            Text("Select...").tag(nil as UUID?)
                            ForEach(locations) { location in
                                Text(location.name).tag(location.id as UUID?)
                            }
                        }
                    }
                }

                if formData.locationType == .custom {
                    TextField("Custom Location", text: $formData.customLocationText)
                }
            }

            // Tags Section
            Section("Tags") {
                if tags.isEmpty {
                    Text("No tags created. Add them in Settings.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags) { tag in
                        Button {
                            toggleTag(tag.name)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(tag.color)
                                    .frame(width: 12, height: 12)
                                Text(tag.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if formData.selectedTags.contains(tag.name) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }

            // Notes Section
            Section("Notes") {
                TextEditor(text: $formData.notes)
                    .frame(minHeight: 100)
            }

            // Options Section
            Section {
                Toggle(isOn: $formData.isFavorite) {
                    Label("Favorite", systemImage: formData.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(formData.isFavorite ? .red : .primary)
                }
            }
        }
    }

    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
            .fill(Color(.systemGray5))
            .frame(height: 200)
            .overlay {
                VStack {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No Cover")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
    }

    private func toggleTag(_ tagName: String) {
        if let index = formData.selectedTags.firstIndex(of: tagName) {
            formData.selectedTags.remove(at: index)
        } else {
            formData.selectedTags.append(tagName)
        }
    }
}

#Preview {
    NavigationStack {
        BookFormView(
            formData: .constant(BookFormData()),
            locations: [],
            tags: [],
            isEditing: false
        )
        .navigationTitle("Add Book")
    }
}
