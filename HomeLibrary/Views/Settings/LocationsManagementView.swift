//
//  LocationsManagementView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct LocationsManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PredefinedLocation.name) private var locations: [PredefinedLocation]

    @State private var showAddSheet = false
    @State private var editingLocation: PredefinedLocation?

    var body: some View {
        List {
            if locations.isEmpty {
                ContentUnavailableView(
                    "No Locations",
                    systemImage: "mappin.slash",
                    description: Text("Add locations to organize where your books are stored.")
                )
            } else {
                ForEach(locations) { location in
                    Button {
                        editingLocation = location
                    } label: {
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundStyle(.orange)
                            Text(location.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .onDelete(perform: deleteLocations)
            }
        }
        .navigationTitle("Locations")
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
            AddLocationSheet()
        }
        .sheet(item: $editingLocation) { location in
            AddLocationSheet(location: location)
        }
    }

    private func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(locations[index])
        }
    }
}

// MARK: - Add/Edit Location Sheet

struct AddLocationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var location: PredefinedLocation?

    @State private var name: String = ""

    var isEditing: Bool {
        location != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Location Name", text: $name)
                } footer: {
                    Text("e.g., \"Living Room - Shelf A\" or \"Bedroom Bookcase\"")
                }
            }
            .navigationTitle(isEditing ? "Edit Location" : "Add Location")
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
                if let location = location {
                    name = location.name
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if let location = location {
            location.name = trimmedName
        } else {
            let newLocation = PredefinedLocation(name: trimmedName)
            modelContext.insert(newLocation)
        }

        dismiss()
    }
}

#Preview {
    NavigationStack {
        LocationsManagementView()
    }
    .modelContainer(for: PredefinedLocation.self, inMemory: true)
}
