import SwiftUI

struct MovieCard: View {

    let movie: Movie

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: movie.posterURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .shimmering()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(movie.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)

                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(movie.releaseYear)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
