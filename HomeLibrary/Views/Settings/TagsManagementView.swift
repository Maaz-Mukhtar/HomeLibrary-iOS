//
//  TagsManagementView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct TagsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \UserTag.name) private var tags: [UserTag]

    @State private var showAddSheet = false
    @State private var editingTag: UserTag?

    var body: some View {
        List {
            if tags.isEmpty {
                ContentUnavailableView(
                    "No Tags",
                    systemImage: "tag.slash",
                    description: Text("Add tags to categorize and organize your books.")
                )
            } else {
                ForEach(tags) { tag in
                    Button {
                        editingTag = tag
                    } label: {
                        HStack {
                            Circle()
                                .fill(tag.color)
                                .frame(width: 16, height: 16)
                            Text(tag.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .onDelete(perform: deleteTags)
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTagSheet()
        }
        .sheet(item: $editingTag) { tag in
            AddTagSheet(tag: tag)
        }
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tags[index])
        }
    }
}

// MARK: - Add/Edit Tag Sheet

struct AddTagSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var tag: UserTag?

    @State private var name: String = ""
    @State private var selectedColorHex: String = TagColors.colors[0]

    var isEditing: Bool {
        tag != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tag Name") {
                    TextField("Name", text: $name)
                }

                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(TagColors.colors, id: \.self) { colorHex in
                            Button {
                                selectedColorHex = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        if selectedColorHex == colorHex {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Preview") {
                    HStack {
                        Spacer()
                        Text(name.isEmpty ? "Tag Name" : name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: selectedColorHex)?.opacity(0.2) ?? .blue.opacity(0.2))
                            .foregroundStyle(Color(hex: selectedColorHex) ?? .blue)
                            .cornerRadius(Constants.CornerRadius.large)
                        Spacer()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Tag" : "Add Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let tag = tag {
                    name = tag.name
                    selectedColorHex = tag.colorHex
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let tag = tag {
            tag.name = trimmedName
            tag.colorHex = selectedColorHex
        } else {
            let newTag = UserTag(name: trimmedName, colorHex: selectedColorHex)
            modelContext.insert(newTag)
        }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        TagsManagementView()
    }
    .modelContainer(for: UserTag.self, inMemory: true)
}
