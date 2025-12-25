//
//  SettingsView.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var books: [Book]
    @Query private var locations: [PredefinedLocation]
    @Query private var tags: [UserTag]
    @Query private var allSettings: [AppSettings]

    private var settings: AppSettings? {
        allSettings.first
    }

    var body: some View {
        List {
            // Appearance
            Section("Appearance") {
                Picker("Mode", selection: Binding<AppearanceMode>(
                    get: {
                        let mode = settings?.appearanceMode ?? .system
                        // Show current system appearance when in system mode
                        if mode == .system {
                            return colorScheme == .dark ? .dark : .light
                        }
                        return mode
                    },
                    set: { newValue in
                        if let settings = settings {
                            settings.appearanceMode = newValue
                        } else {
                            let newSettings = AppSettings()
                            newSettings.appearanceMode = newValue
                            modelContext.insert(newSettings)
                        }
                    }
                )) {
                    Text("Light").tag(AppearanceMode.light)
                    Text("Dark").tag(AppearanceMode.dark)
                }
                .pickerStyle(.segmented)

                if settings?.appearanceMode != .system && settings != nil {
                    Button("Use Device Setting") {
                        settings?.appearanceMode = .system
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            // Library Stats
            Section("Library") {
                HStack {
                    Label("Total Books", systemImage: "books.vertical")
                    Spacer()
                    Text("\(books.count)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Favorites", systemImage: "heart.fill")
                        .foregroundStyle(.red)
                    Spacer()
                    Text("\(books.filter { $0.isFavorite }.count)")
                        .foregroundStyle(.secondary)
                }
            }

            // Organization
            Section("Organization") {
                NavigationLink {
                    LocationsManagementView()
                } label: {
                    HStack {
                        Label("Locations", systemImage: "mappin")
                        Spacer()
                        Text("\(locations.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink {
                    TagsManagementView()
                } label: {
                    HStack {
                        Label("Tags", systemImage: "tag")
                        Spacer()
                        Text("\(tags.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Storage
            Section("Storage") {
                HStack {
                    Label("Storage Mode", systemImage: "icloud")
                    Spacer()
                    Text("Local Only")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Cloud Sync", systemImage: "arrow.triangle.2.circlepath")
                    Spacer()
                    Text("Coming Soon")
                        .foregroundStyle(.orange)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.small)
                }
            }

            // About
            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text(Constants.appVersion)
                        .foregroundStyle(.secondary)
                }

                Link(destination: URL(string: "https://github.com/Maaz-Mukhtar/HomeLibrary-iOS")!) {
                    HStack {
                        Label("GitHub", systemImage: "link")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [Book.self, PredefinedLocation.self, UserTag.self], inMemory: true)
}
