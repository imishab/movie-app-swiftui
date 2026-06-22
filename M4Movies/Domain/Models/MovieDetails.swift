import Foundation

struct MovieDetails: Identifiable, Hashable {

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
    let genres: [Genre]
    let status: String
    let originalLanguage: String
    let homepage: String?
    let budget: Int
    let revenue: Int
    let trailer: MovieTrailer?
}

struct Genre: Identifiable, Hashable {

    let id: Int
    let name: String
}

struct MovieTrailer: Identifiable, Hashable {

    let id: String
    let name: String
    let site: String
    let key: String
}

extension MovieTrailer {

    var watchURL: URL? {
        switch site.lowercased() {
        case "youtube":
            return URL(string: "https://www.youtube.com/watch?v=\(key)")
        case "vimeo":
            return URL(string: "https://vimeo.com/\(key)")
        default:
            return nil
        }
    }
}

extension MovieDetails {

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "\(Config.imageBaseURL)\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return URL(string: "\(Config.backdropImageBaseURL)\(backdropPath)")
    }

    var releaseYear: String {
        String(releaseDate.prefix(4))
    }

    var runtimeFormatted: String? {
        guard let runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    var languageName: String {
        Locale.current.localizedString(forLanguageCode: originalLanguage)?.capitalized
            ?? originalLanguage.uppercased()
    }

    var formattedBudget: String? {
        budget > 0 ? formatCurrency(budget) : nil
    }

    var formattedRevenue: String? {
        revenue > 0 ? formatCurrency(revenue) : nil
    }

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
