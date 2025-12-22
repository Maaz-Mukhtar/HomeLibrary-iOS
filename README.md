# Home Library iOS

A native iOS app for managing your personal book collection. Built with SwiftUI and SwiftData.

## Features

### Phase 1 (Current)
- [x] Manual book entry with full form
- [x] Book library with grid and list views
- [x] Search across title, author, ISBN, tags, notes
- [x] Filter by genre, location, tags, favorites
- [x] 6 sort options (date, title, author, genre, location, favorites)
- [x] Book detail view with edit and delete
- [x] Locations management (CRUD)
- [x] Tags management with colors (CRUD)
- [x] Favorites toggle
- [x] Duplicate detection

### Upcoming Features
- [ ] **Phase 4**: Barcode scanning (ISBN lookup via camera)
- [ ] **Phase 5**: OCR from book cover and ISBN photos
- [ ] **Phase 8**: Firebase cloud sync

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Tech Stack

- **SwiftUI** - Declarative UI framework
- **SwiftData** - Persistence layer
- **AVFoundation** - Camera/barcode scanning (Phase 4)
- **Vision** - OCR text recognition (Phase 5)

## Project Structure

```
HomeLibrary/
├── Models/           # SwiftData models
├── Views/            # SwiftUI views
│   ├── Library/      # Grid, list, filters
│   ├── AddBook/      # Entry methods, form
│   ├── BookDetail/   # Detail, edit views
│   ├── Search/       # Search view
│   ├── Settings/     # Settings, locations, tags
│   └── Components/   # Reusable UI components
├── ViewModels/       # State management
├── Services/         # API, Camera, OCR
├── Repositories/     # Data access layer
├── Extensions/       # Swift extensions
└── Utilities/        # Constants, helpers
```

## Getting Started

1. Clone the repository
2. Open `HomeLibrary.xcodeproj` in Xcode
3. Build and run on iOS 17+ simulator or device

## Related

This app is the iOS native version of [Home Library Web App](https://github.com/Maaz-Mukhtar/Home_Library).

## License

MIT
