# M4Movies
### iOS App Overview · June 2026

---

## What is M4Movies?

M4Movies is a native iOS movie discovery app built entirely with **SwiftUI** and **Swift Concurrency**. It connects to the **TMDB (The Movie Database) API** to let users browse, search, and save their favourite movies all with a polished dark-mode UI and smooth animations.

> Zero third-party dependencies. 100% Apple frameworks.

---

## Feature Walkthrough

| # | Feature | What it does |
|---|---------|-------------|
| 1 | **Splash Screen** | Animated logo fade-in on launch (~1.8s) |
| 2 | **Home** | Browse movies across 4 TMDB categories with infinite scroll |
| 3 | **Movie Detail** | Hero backdrop, rating, runtime, genres, budget/revenue |
| 4 | **Search** | Debounced live search with recent search history |
| 5 | **Favourites** | Save movies locally via CoreData; persist across sessions |
| 6 | **Settings** | Clear search history, view app version |
| 7 | **Skeleton Loading** | Shimmer placeholders while content loads |
| 8 | **Zoom Transitions** | iOS 18 card-to-detail zoom animation |

---

## Architecture : Clean Architecture + MVVM

The app is split into **3 clear layers**. Each layer only talks to the one below it.

```
┌─────────────────────────────────────────────┐
│              PRESENTATION LAYER             │
│   SwiftUI Views  +  @Observable ViewModels  │
└─────────────────────┬───────────────────────┘
                      │  calls protocols
┌─────────────────────▼───────────────────────┐
│                DOMAIN LAYER                 │
│   Models (Movie, Genre…)  +  Protocols      │
│   (MovieRepository, FavoritesRepository…)   │
└─────────────────────┬───────────────────────┘
                      │  implemented by
┌─────────────────────▼───────────────────────┐
│                 DATA LAYER                  │
│   API Client (URLSession)  +  CoreData      │
│   Repository Implementations  +  DTOs       │
└─────────────────────────────────────────────┘
```

### Why this structure?
- **Domain layer has zero framework imports** : pure Swift, fully testable
- **Swapping the API or database** only changes the Data layer
- **ViewModels never touch URLSession or CoreData directly** : they call protocols

---

## File Structure

```
M4Movies/
│
├── App/
│   └── M4MoviesApp.swift          ← @main entry point, dark mode, splash logic
│
├── Resources/
│   └── Config.swift               ← TMDB API key & base URLs
│
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift        ← Generic async/await HTTP client
│   │   ├── Endpoint.swift         ← URL builder for all 3 API routes
│   │   └── NetworkError.swift     ← Typed error enum
│   └── Persistence/
│       ├── PersistenceController.swift  ← CoreData stack (code-defined, no .xcdatamodeld)
│       ├── FavoriteMovieEntity.swift    ← CoreData entity: saved movies
│       └── RecentSearchEntity.swift     ← CoreData entity: search history
│
├── Domain/                        ← Pure Swift no framework imports
│   ├── Models/
│   │   ├── Movie.swift            ← Core movie value type
│   │   ├── MovieDetails.swift     ← Extended detail model
│   │   ├── MovieCategory.swift    ← Enum: popular/nowPlaying/topRated/upcoming
│   │   ├── PagedMovies.swift      ← Pagination wrapper
│   │   └── RecentSearch.swift     ← Search history model
│   └── Repositories/              ← Protocols only no implementations here
│       ├── MovieRepository.swift
│       ├── FavoritesRepository.swift
│       └── RecentSearchRepository.swift
│
├── Data/                          ← Concrete implementations
│   ├── DTOs/
│   │   ├── MovieDTO.swift         ← JSON → Movie mapping
│   │   ├── MovieDetailsDTO.swift  ← JSON → MovieDetails mapping
│   │   └── ResponseDTO.swift      ← Paginated list wrapper
│   └── Repositories/
│       ├── MovieRepositoryImpl.swift        ← Calls TMDB API
│       ├── FavoritesRepositoryImpl.swift    ← Reads/writes CoreData
│       └── RecentSearchRepositoryImpl.swift ← Reads/writes CoreData
│
└── Presentation/
    ├── Main/
    │   ├── MainTabView.swift      ← Root TabView (4 tabs)
    │   ├── AppTab.swift           ← Tab enum with icons/labels
    │   └── SplashView.swift       ← Animated logo splash
    ├── Home/
    │   ├── HomeView.swift         ← Movie grid + category picker
    │   └── HomeViewModel.swift    ← Pagination, refresh, category switching
    ├── Search/
    │   ├── SearchView.swift       ← Search bar, recents, results
    │   └── SearchViewModel.swift  ← Debounce, task cancellation, state machine
    ├── MovieDetails/
    │   ├── MovieDetailsView.swift     ← Hero layout, stats, genres, info grid
    │   └── MovieDetailsViewModel.swift← Fetches full movie details by ID
    ├── Favorites/
    │   └── FavoritesView.swift    ← Saved movies grid, context menu remove
    ├── Settings/
    │   └── SettingsView.swift     ← Clear history, app version
    └── Common/
        ├── FavoritesStore.swift   ← Shared @Observable favorites state
        ├── MovieCard.swift        ← Reusable poster card component
        ├── MovieCardSkeleton.swift← Shimmer placeholder card
        ├── MovieGridSkeleton.swift← Full grid skeleton
        ├── LoadMoreFooter.swift   ← Pagination footer / retry
        └── Shimmer.swift          ← Shimmer animation ViewModifier
```

---

## Core Technologies

### SwiftUI
Every screen is built with SwiftUI no UIKit at all. We use modern SwiftUI features:
- `NavigationStack` + `NavigationLink(value:)` for type-safe navigation
- `.navigationDestination(for:)` for declarative routing
- `TabView` with custom `AppTab` enum
- `.searchable()` for the search screen
- `AsyncImage` for poster and backdrop image loading

### Swift Concurrency (async/await)
All network calls and ViewModel logic use `async/await` no Combine, no callbacks.

```swift
// Example: fetching movies
func loadMovies() async {
    isLoading = true
    do {
        let result = try await movieRepository.fetchMovies(category: category, page: page)
        movies.append(contentsOf: result.movies)
    } catch {
        self.error = error
    }
    isLoading = false
}
```

Tasks are cancelled properly in Search to avoid stale results from slow network responses.

### @Observable Macro (Swift 5.9)
ViewModels use the new `@Observable` macro instead of `ObservableObject` + `@Published`. This is more efficient SwiftUI only re-renders views that read a specific property when that property changes.

```swift
@Observable
@MainActor
final class HomeViewModel {
    var movies: [Movie] = []
    var isLoading = false
    var selectedCategory: MovieCategory = .popular
    // ...
}
```

### CoreData (Code-Defined Model)
We store **Favourites** and **Recent Searches** locally using CoreData. Unusually, the data model is defined entirely in Swift code no `.xcdatamodeld` file. This keeps the model version-controlled just like any other Swift file.

```
FavoriteMovieEntity      RecentSearchEntity
─────────────────        ──────────────────
id (Int64)               keyword (String)
title (String)           searchedAt (Date)
posterPath (String)
voteAverage (Double)
favoritedAt (Date)
... + more fields
```

Key CoreData features used:
- **Uniqueness constraints** on `FavoriteMovieEntity.id` prevents duplicates
- **NSBatchDeleteRequest** for bulk-deleting search history
- **In-memory store** mode available for testing

### Networking (URLSession)
A lightweight `APIClient` wraps `URLSession` with a generic `fetch<T: Decodable>` method. Three endpoints:

| Endpoint | URL |
|----------|-----|
| Movie list | `/movie/{category}?page=N` |
| Search | `/search/movie?query=X&page=N` |
| Movie details | `/movie/{id}` |

All image loading uses SwiftUI's built-in `AsyncImage` no image caching library needed.

---

## Navigation Architecture

```
MainTabView (TabView)
│
├── Tab 1: Home NavigationStack
│   └── HomeView → [tap card] → MovieDetailsView
│
├── Tab 2: Search NavigationStack
│   └── SearchView (NavigationPath) → [tap result] → MovieDetailsView
│
├── Tab 3: Favourites NavigationStack
│   └── FavoritesView → [tap card] → MovieDetailsView
│
└── Tab 4: Settings NavigationStack
    └── SettingsView
```

**Each tab has its own independent `NavigationStack`** switching tabs preserves each tab's navigation state (standard iOS behaviour).

**Movie cards** use value-based navigation:
```swift
NavigationLink(value: movie) { MovieCard(movie: movie) }
// Resolved by:
.navigationDestination(for: Movie.self) { movie in MovieDetailsView(movie: movie) }
```

**Zoom transition** (iOS 18+): tapping a card zooms into the detail view from the exact card position.

---

## Shared State FavoritesStore

`FavoritesStore` is an `@Observable` singleton injected via SwiftUI's `.environment()`. It holds an in-memory `Set<Int>` of favourite movie IDs so any view can check `isFavourite(movieID:)` in O(1) without hitting CoreData on every render.

```
App starts
    │
    ▼
FavoritesStore loads all favourite IDs from CoreData into memory
    │
    ├──► MovieCard reads isFavourite → shows red/grey heart
    ├──► MovieDetailsView reads isFavourite → shows heart button state
    └──► FavoritesView reads all favourites → renders grid
```

When a user toggles a favourite, `FavoritesStore` updates both CoreData and the in-memory set atomically.

---

## Key Design Patterns

| Pattern | Where used | Why |
|---------|-----------|-----|
| **Repository pattern** | Domain + Data layers | Decouples ViewModels from data sources |
| **Protocol-oriented programming** | `MovieRepository`, `FavoritesRepository` | Enables unit testing with mock implementations |
| **Value types for domain models** | All `Domain/Models/` are structs | Thread safety, predictable state |
| **DTO → Domain mapping** | `toDomain()` methods on all DTOs | Keeps API concerns out of the domain |
| **State machine in ViewModel** | `SearchViewModel` (idle/loading/results/noResults/error) | Clear, exhaustive UI state handling |
| **Prefetch-based pagination** | `HomeViewModel`, `SearchViewModel` | Loads next page 5 items before end of scroll |
| **Debounce via Task** | `SearchViewModel` (350ms delay) | Prevents API flood on every keystroke |
| **Shimmer skeleton** | `MovieGridSkeleton`, `MovieCardSkeleton` | Better perceived performance vs. spinner |

---

## Data Flow End to End

Here's how a user browsing the Home screen triggers everything:

```
User opens app
    │
    ▼
SplashView (1.8s) → MainTabView → HomeView
    │
    ▼
HomeView.task { await viewModel.loadInitialMovies() }
    │
    ▼
HomeViewModel calls MovieRepository.fetchMovies(category: .popular, page: 1)
    │
    ▼
MovieRepositoryImpl calls APIClient.fetch(Endpoint.movieList)
    │
    ▼
URLSession hits TMDB API → returns JSON
    │
    ▼
JSON decoded into MovieListResponseDTO → mapped to [Movie] via toDomain()
    │
    ▼
HomeViewModel.movies updated → SwiftUI re-renders grid
    │
    ▼
MovieCard shows AsyncImage (poster) + title + rating
    │
    ▼
User scrolls near bottom → HomeViewModel.loadMoreIfNeeded() → page 2 fetched
```

---

## What Makes This App Stand Out

- **Zero dependencies** : no CocoaPods, no SPM packages. Easier to build, maintain, and audit.
- **Modern Swift throughout** : `@Observable`, `async/await`, value types, protocol-oriented design.
- **CoreData without a .xcdatamodeld** : the entire schema is code-defined, making it fully diff-able in git.
- **Clean Architecture respected** : Domain layer has no framework imports. You could swap the API or database without touching a single ViewModel.
- **iOS 18 polish** : zoom navigation transitions, `ContentUnavailableView`, `.symbolEffect(.bounce)` on the heart icon.
- **Accessibility considered** : shimmer animations respect `reduceMotion`, all buttons have accessibility labels.

---

## Tech Stack Summary

```
Language        Swift 5.9+
UI Framework    SwiftUI (100% no UIKit)
State Mgmt      @Observable macro + @MainActor
Concurrency     async/await + structured concurrency
Networking      URLSession (native)
Image Loading   AsyncImage (native)
Local Storage   CoreData (code-defined model)
Architecture    Clean Architecture + MVVM
Navigation      NavigationStack (value-based)
API             TMDB (The Movie Database)
Dependencies    None (zero third-party packages)
Min Target      iOS 18 (zoom transitions)
```

---