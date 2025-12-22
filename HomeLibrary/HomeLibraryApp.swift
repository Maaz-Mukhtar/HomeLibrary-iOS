//
//  HomeLibraryApp.swift
//  HomeLibrary
//
//  Created by Maaz Mukhtar
//

import SwiftUI
import SwiftData

@main
struct HomeLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Book.self,
            PredefinedLocation.self,
            UserTag.self,
            AppSettings.self
        ])
    }
}
