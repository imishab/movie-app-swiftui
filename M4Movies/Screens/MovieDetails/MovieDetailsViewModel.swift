import Foundation

@MainActor
@Observable
final class MovieDetailsViewModel {

    var details: MovieDetails?
    var isLoading = false
    var errorMessage: String?

    private let movieID: Int
    private let repository: MovieRepository

    init(movieID: Int, repository: MovieRepository = MovieRepositoryImpl()) {
        self.movieID = movieID
        self.repository = repository
    }

    func load() async {
        guard details == nil else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            details = try await repository.fetchMovieDetails(id: movieID)
        } catch {
            errorMessage = "Failed to load details. Please try again."
        }
    }

    func retry() async {
        errorMessage = nil
        details = nil
        await load()
    }
}
