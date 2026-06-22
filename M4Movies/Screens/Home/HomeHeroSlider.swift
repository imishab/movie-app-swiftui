import SwiftUI

struct HomeHeroSlider: View {

    let movies: [Movie]
    let transitionNamespace: Namespace.ID

    @State private var visibleID: Movie.ID?

    private let cardSpacing: CGFloat = 14
    private let sidePadding: CGFloat = 16
    private let cardWidthRatio: CGFloat = 0.86
    private let cardAspect: CGFloat = 2.0 / 3.0

    var body: some View {
        VStack(spacing: 14) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(movies) { movie in
                        let sourceID = HomeMovieTransitionSource.hero(movie.id)

                        NavigationLink(
                            value: HomeMovieRoute(
                                movie: movie,
                                sourceID: sourceID
                            )
                        ) {
                            HeroCard(movie: movie)
                                .aspectRatio(cardAspect, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .matchedTransitionSource(
                            id: sourceID,
                            in: transitionNamespace
                        )
                        .containerRelativeFrame(.horizontal, alignment: .center) { width, _ in
                            width * cardWidthRatio
                        }
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, sidePadding, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $visibleID)

            PageIndicator(movies: movies, currentID: visibleID)
        }
        .onAppear {
            if visibleID == nil { visibleID = movies.first?.id }
        }
    }
}

// MARK: - Hero Card

private struct HeroCard: View {

    let movie: Movie

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            poster
            gradient
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .topLeading) {
            FeaturedBadge()
                .padding(14)
        }
    }

    private var poster: some View {
        AsyncImage(url: movie.posterURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .shimmering()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var gradient: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black.opacity(0.15), location: 0.45),
                .init(color: .black.opacity(0.6), location: 0.75),
                .init(color: .black.opacity(0.95), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(movie.title)
                .font(.title.bold())
                .foregroundStyle(.white)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 1)

            HStack(spacing: 12) {
                Label {
                    Text(String(format: "%.1f", movie.voteAverage))
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }

                bullet
                Text(movie.releaseYear)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.95))
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bullet: some View {
        Text("•").foregroundStyle(.white.opacity(0.55))
    }
}

// MARK: - Featured Badge

private struct FeaturedBadge: View {

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.orange)

            Text("Featured")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.15), lineWidth: 0.5))
    }
}

// MARK: - Page Indicator

private struct PageIndicator: View {

    let movies: [Movie]
    let currentID: Movie.ID?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(movies) { movie in
                Capsule()
                    .fill(movie.id == currentID ? Color.primary : Color.primary.opacity(0.25))
                    .frame(width: movie.id == currentID ? 18 : 6, height: 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentID)
            }
        }
        .accessibilityHidden(true)
    }
}
