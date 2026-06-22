import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var topRatedMovies: [Movie] = []
    var featuredMovies: [Movie] = []
    var isLoading = false
    var errorMessage: String?
    var refreshError: String?

    private let repository: MovieRepository
    private let featuredCount = 5
    private let sectionPreviewCount = 12

    init(repository: MovieRepository = MovieRepositoryImpl()) {
        self.repository = repository
    }

    func loadContent() async {
        guard popularMovies.isEmpty,
              nowPlayingMovies.isEmpty,
              topRatedMovies.isEmpty
        else { return }

        isLoading = true
        await fetchSections(isRefresh: false)
        isLoading = false
    }

    func refresh() async {
        await fetchSections(isRefresh: true)
    }

    func retry() async {
        errorMessage = nil
        isLoading = true
        await fetchSections(isRefresh: false)
        isLoading = false
    }

    private func fetchSections(isRefresh: Bool) async {
        async let popularResult = fetchFirstPage(for: .popular)
        async let nowPlayingResult = fetchFirstPage(for: .nowPlaying)
        async let topRatedResult = fetchFirstPage(for: .topRated)

        let (popular, nowPlaying, topRated) = await (
            popularResult,
            nowPlayingResult,
            topRatedResult
        )

        var loadedAnySection = false

        if let popular {
            popularMovies = Array(popular.movies.prefix(sectionPreviewCount))
            featuredMovies = Array(popular.movies.prefix(featuredCount))
            loadedAnySection = true
        }

        if let nowPlaying {
            nowPlayingMovies = Array(nowPlaying.movies.prefix(sectionPreviewCount))
            loadedAnySection = true
        }

        if let topRated {
            topRatedMovies = Array(topRated.movies.prefix(sectionPreviewCount))
            loadedAnySection = true
        }

        if loadedAnySection {
            errorMessage = nil
            refreshError = nil
        } else if isRefresh && hasVisibleContent {
            refreshError = "Couldn't refresh movies. Please try again."
        } else {
            errorMessage = "Failed to load movies. Please try again."
        }
    }

    private func fetchFirstPage(for category: MovieCategory) async -> PagedMovies? {
        do {
            return try await repository.fetchMovies(category: category, page: 1)
        } catch {
            return nil
        }
    }

    private var hasVisibleContent: Bool {
        !popularMovies.isEmpty || !nowPlayingMovies.isEmpty || !topRatedMovies.isEmpty
    }
}
