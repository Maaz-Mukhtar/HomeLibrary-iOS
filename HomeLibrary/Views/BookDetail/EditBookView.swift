//
//  EditBookView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct EditBookView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var locations: [PredefinedLocation]
    @Query private var tags: [UserTag]

    @Bindable var book: Book

    @State private var formData: BookFormData
    @State private var isSaving = false

    init(book: Book) {
        self.book = book
        self._formData = State(initialValue: BookFormData())
    }

    var body: some View {
        BookFormView(
            formData: $formData,
            locations: locations,
            tags: tags,
            isEditing: true
        )
        .navigationTitle("Edit Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .fontWeight(.semibold)
                .disabled(!formData.isValid || isSaving)
            }
        }
        .onAppear {
            formData = BookFormData(from: book, locations: locations)
        }
    }

    private func saveChanges() {
        isSaving = true

        book.title = formData.title.trimmingCharacters(in: .whitespacesAndNewlines)
        book.authors = formData.authorsArray
        book.genre = formData.genre.isEmpty ? nil : formData.genre
        book.isbn = formData.isbn.isEmpty ? nil : formData.isbn
        book.notes = formData.notes.isEmpty ? nil : formData.notes
        book.isFavorite = formData.isFavorite
        book.tagNames = formData.selectedTags
        book.location = formData.bookLocation
        book.coverImageData = formData.coverImageData
        book.coverImageURL = formData.coverImageURL
        book.lastModified = Date()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditBookView(
            book: Book(
                title: "The Great Gatsby",
                authors: ["F. Scott Fitzgerald"],
                genre: "Fiction"
            )
        )
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self, UserTag.self], inMemory: true)
}
