import Foundation

struct Movie: Identifiable, Codable, Hashable {

    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
}

extension Movie {

    var posterURL: URL? {

        guard let posterPath else {
            return nil
        }

        return URL(
            string:
            "\(Config.imageBaseURL)\(posterPath)"
        )
    }

    var releaseYear: String {
        String(releaseDate.prefix(4))
    }
}