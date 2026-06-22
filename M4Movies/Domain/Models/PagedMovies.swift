import Foundation

struct PagedMovies {

    let movies: [Movie]
    let page: Int
    let totalPages: Int

    var hasMorePages: Bool {
        page < totalPages
    }
}
