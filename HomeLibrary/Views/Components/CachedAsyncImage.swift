//
//  CachedAsyncImage.swift
//  HomeLibrary
//
//  Created by Claude Code
//

import SwiftUI

/// An async image view with in-memory caching
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = url, !isLoading else { return }

        let cacheKey = url.absoluteString

        // Check cache first
        if let cachedImage = ImageCacheService.shared.image(forKey: cacheKey) {
            self.image = cachedImage
            return
        }

        isLoading = true

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    ImageCacheService.shared.setImage(uiImage, forKey: cacheKey)
                    await MainActor.run {
                        self.image = uiImage
                    }
                }
            } catch {
                // Image failed to load, keep showing placeholder
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
