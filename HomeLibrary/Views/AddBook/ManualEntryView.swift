//
//  ManualEntryView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct ManualEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var locations: [PredefinedLocation]
    @Query private var tags: [UserTag]
    @Query private var books: [Book]

    @State private var formData: BookFormData
    @State private var showDuplicateWarning = false
    @State private var duplicateBook: Book?
    @State private var isSaving = false

    init(initialData: BookFormData = BookFormData()) {
        _formData = State(initialValue: initialData)
    }

    var body: some View {
        BookFormView(
            formData: $formData,
            locations: locations,
            tags: tags,
            isEditing: false
        )
        .navigationTitle("Add Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveBook()
                }
                .fontWeight(.semibold)
                .disabled(!formData.isValid || isSaving)
            }
        }
        .alert("Duplicate Book Found", isPresented: $showDuplicateWarning) {
            Button("View Existing") {
                // Navigate to existing book
                dismiss()
            }
            Button("Save Anyway") {
                saveBookConfirmed()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let duplicate = duplicateBook {
                Text("A book with the title \"\(duplicate.title)\" by \(duplicate.authorsDisplay) already exists in your library.")
            }
        }
    }

    private func saveBook() {
        // Check for duplicates
        if let duplicate = checkForDuplicate() {
            duplicateBook = duplicate
            showDuplicateWarning = true
            return
        }

        saveBookConfirmed()
    }

    private func saveBookConfirmed() {
        isSaving = true

        let book = Book(
            title: formData.title.trimmingCharacters(in: .whitespacesAndNewlines),
            authors: formData.authorsArray,
            genre: formData.genre.isEmpty ? nil : formData.genre,
            coverImageData: formData.coverImageData,
            isbn: formData.isbn.isEmpty ? nil : formData.isbn,
            location: formData.bookLocation,
            notes: formData.notes.isEmpty ? nil : formData.notes,
            tagNames: formData.selectedTags,
            isFavorite: formData.isFavorite
        )

        modelContext.insert(book)

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        dismiss()
    }

    private func checkForDuplicate() -> Book? {
        let normalizedTitle = formData.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedAuthors = Set(formData.authorsArray.map { $0.lowercased() })

        return books.first { book in
            let bookTitle = book.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let bookAuthors = Set(book.authors.map { $0.lowercased() })

            return bookTitle == normalizedTitle && !bookAuthors.isDisjoint(with: normalizedAuthors)
        }
    }
}

#Preview {
    NavigationStack {
        ManualEntryView()
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self, UserTag.self], inMemory: true)
}
