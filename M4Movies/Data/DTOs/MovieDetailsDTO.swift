import Foundation

struct MovieDetailsDTO: Codable {

    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let tagline: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let genres: [GenreDTO]
    let status: String
    let originalLanguage: String
    let homepage: String?
    let budget: Int
    let revenue: Int
    let videos: VideoResponseDTO?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, tagline, runtime, genres, status, homepage, budget, revenue
        case videos
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
    }
}

struct GenreDTO: Codable {

    let id: Int
    let name: String
}

struct VideoResponseDTO: Codable {

    let results: [VideoDTO]
}

struct VideoDTO: Codable {

    let id: String
    let name: String
    let key: String
    let site: String
    let type: String
    let official: Bool
    let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, key, site, type, official
        case publishedAt = "published_at"
    }
}

extension MovieDetailsDTO {

    func toDomain() -> MovieDetails {
        MovieDetails(
            id: id,
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            tagline: tagline,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            runtime: runtime,
            voteAverage: voteAverage,
            voteCount: voteCount,
            genres: genres.map { Genre(id: $0.id, name: $0.name) },
            status: status,
            originalLanguage: originalLanguage,
            homepage: homepage,
            budget: budget,
            revenue: revenue,
            trailer: preferredTrailer
        )
    }

    private var preferredTrailer: MovieTrailer? {
        let supportedTrailers = videos?.results.filter {
            $0.type.caseInsensitiveCompare("Trailer") == .orderedSame &&
            ["youtube", "vimeo"].contains($0.site.lowercased())
        } ?? []

        let selected = supportedTrailers.sorted { lhs, rhs in
            trailerScore(lhs) > trailerScore(rhs)
        }.first

        guard let selected else { return nil }

        return MovieTrailer(
            id: selected.id,
            name: selected.name,
            site: selected.site,
            key: selected.key
        )
    }

    private func trailerScore(_ video: VideoDTO) -> Int {
        var score = 0
        if video.official { score += 100 }
        if video.site.caseInsensitiveCompare("YouTube") == .orderedSame { score += 20 }
        if video.name.localizedCaseInsensitiveContains("official trailer") { score += 10 }
        return score
    }
}
