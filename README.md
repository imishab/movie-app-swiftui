# M4Movies

M4Movies is a native iOS movie-discovery app built with SwiftUI. It uses
[The Movie Database (TMDB)](https://www.themoviedb.org/) API to browse,
search, and save movies in a polished dark-mode interface.

![M4Movies logo](M4Movies/Assets.xcassets/logo.imageset/logo.png)

## Features

- Browse popular, now-playing, top-rated, and upcoming movies
- Search movies with debouncing and recent-search history
- View movie details, ratings, genres, runtime, budget, and revenue
- Save favourite movies locally with Core Data
- Infinite scrolling and pull-to-refresh
- Skeleton loading and shimmer animations
- Card-to-detail zoom transitions on iOS 18
- Persistent favourites and search history

## Tech Stack

- Swift and SwiftUI
- Swift Concurrency (`async`/`await`)
- Observation (`@Observable`)
- URLSession
- Core Data with a code-defined model
- Clean Architecture and MVVM
- No third-party dependencies

## Requirements

- macOS with Xcode
- iOS 18.6 or later
- A free [TMDB API key](https://www.themoviedb.org/settings/api)

## Getting Started

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd M4Movies
   ```

2. Open `M4Movies.xcodeproj` in Xcode.

3. Create your local configuration from the provided example:

   ```bash
   cp M4Movies/Resources/Config.swift.example M4Movies/Resources/Config.swift
   ```

4. Add your TMDB API key in `M4Movies/Resources/Config.swift`:

   ```swift
   static let apiKey = "YOUR_TMDB_API_KEY"
   ```

5. Select an iOS 18.6+ simulator or device, then build and run the app.

`Config.swift` is ignored by Git. Only the placeholder
`Config.swift.example` should be committed.

## Architecture

The project follows Clean Architecture with MVVM:

```text
Presentation
SwiftUI views and observable ViewModels
        ↓
Domain
Models and repository protocols
        ↓
Data
TMDB API, DTO mapping, and Core Data repositories
```

## Project Structure

```text
M4Movies/
├── App/             App entry point
├── Core/            Networking and persistence
├── Data/            DTOs and repository implementations
├── Domain/          Models and repository protocols
├── Presentation/    SwiftUI screens, ViewModels, and shared components
├── Resources/       App configuration
└── Docs/            Detailed app documentation
```

For a deeper technical walkthrough, see
[About M4Movies](M4Movies/Docs/about-app.md).

## Acknowledgements

This product uses the TMDB API but is not endorsed or certified by TMDB.
