import Foundation

final class MovieRepositoryImpl: MovieRepository {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchMovies(category: MovieCategory, page: Int) async throws -> PagedMovies {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .movieList(category: category, page: page)
        )
        return PagedMovies(
            movies: response.results.map { $0.toDomain() },
            page: response.page,
            totalPages: response.totalPages
        )
    }

    func searchMovies(query: String, page: Int) async throws -> PagedMovies {
        let response: MovieListResponseDTO = try await apiClient.request(
            endpoint: .search(query: query, page: page)
        )
        return PagedMovies(
            movies: response.results.map { $0.toDomain() },
            page: response.page,
            totalPages: response.totalPages
        )
    }

    func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        let response: MovieDetailsDTO = try await apiClient.request(
            endpoint: .details(id: id)
        )
        return response.toDomain()
    }
}
