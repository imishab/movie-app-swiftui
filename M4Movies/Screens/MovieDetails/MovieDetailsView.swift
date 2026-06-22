import SwiftUI

struct MovieDetailsView: View {

    let movie: Movie

    @State private var viewModel: MovieDetailsViewModel
    @Environment(\.dismiss) private var dismiss

    init(movie: Movie) {
        self.movie = movie
        self._viewModel = State(wrappedValue: MovieDetailsViewModel(movieID: movie.id))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeroSection(movie: movie, details: viewModel.details)

                VStack(alignment: .leading, spacing: 24) {
                    QuickStatsRow(movie: movie, details: viewModel.details)

                    if let error = viewModel.errorMessage {
                        InlineErrorView(message: error) {
                            Task { await viewModel.retry() }
                        }
                    } else if viewModel.isLoading {
                        DetailsSkeleton()
                    } else if let details = viewModel.details {
                        DetailsContent(details: details)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .top)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            DismissButton { dismiss() }
        }
        .overlay(alignment: .topTrailing) {
            FavoriteButton(movie: movie)
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Favorite Button

private struct FavoriteButton: View {

    let movie: Movie

    @Environment(FavoritesStore.self) private var favoritesStore

    var body: some View {
        let isFavorite = favoritesStore.isFavorite(movie.id)

        Button {
            favoritesStore.toggle(movie)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isFavorite ? .red : .white)
                .symbolEffect(.bounce, value: isFavorite)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
        }
        .padding(.trailing, 16)
        .padding(.top, 8)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
}

// MARK: - Hero Section

private struct HeroSection: View {

    let movie: Movie
    let details: MovieDetails?

    private let heroHeight: CGFloat = 360

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                backdrop(size: proxy.size)
                gradient
                titleBlock
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
    }

    @ViewBuilder
    private func backdrop(size: CGSize) -> some View {
        AsyncImage(url: details?.backdropURL ?? movie.posterURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()
            default:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .shimmering()
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private var gradient: some View {
        LinearGradient(
            colors: [
                .black.opacity(0.0),
                .black.opacity(0.35),
                .black.opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(details?.title ?? movie.title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
                .lineLimit(3)

            if let tagline = details?.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline.italic())
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Quick Stats

private struct QuickStatsRow: View {

    let movie: Movie
    let details: MovieDetails?

    var body: some View {
        HStack(spacing: 14) {
            StatPill(
                systemImage: "star.fill",
                tint: .yellow,
                text: String(format: "%.1f", details?.voteAverage ?? movie.voteAverage)
            )

            StatPill(
                systemImage: "calendar",
                tint: .blue,
                text: details?.releaseYear ?? movie.releaseYear
            )

            if let runtime = details?.runtimeFormatted {
                StatPill(
                    systemImage: "clock",
                    tint: .orange,
                    text: runtime
                )
            }

            Spacer(minLength: 0)
        }
    }
}

private struct StatPill: View {

    let systemImage: String
    let tint: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(text)
                .foregroundStyle(.primary)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}

// MARK: - Details Content

private struct DetailsContent: View {

    let details: MovieDetails

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            TrailerAction(trailer: details.trailer)

            if !details.genres.isEmpty {
                GenreChips(genres: details.genres)
            }

            Section(title: "Overview") {
                Text(details.overview.isEmpty ? "No overview available." : details.overview)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(4)
            }

            Section(title: "Information") {
                InfoGrid(details: details)
            }
        }
    }
}

private struct TrailerAction: View {

    let trailer: MovieTrailer?

    @Environment(\.openURL) private var openURL

    var body: some View {
        if let trailer, let watchURL = trailer.watchURL {
            Button {
                openURL(watchURL)
            } label: {
                Label("Watch Trailer", systemImage: "play.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens \(trailer.name) on \(trailer.site)")
        } else {
            Label("Trailer Not Available", systemImage: "play.slash")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        }
    }
}

private struct GenreChips: View {

    let genres: [Genre]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(genres) { genre in
                    Text(genre.name)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(.separator), lineWidth: 0.5)
                        )
                }
            }
        }
    }
}

private struct InfoGrid: View {

    let details: MovieDetails

    var body: some View {
        VStack(spacing: 0) {
            InfoRow(label: "Status", value: details.status)
            Divider()
            InfoRow(label: "Original Title", value: details.originalTitle)
            Divider()
            InfoRow(label: "Language", value: details.languageName)
            Divider()
            InfoRow(label: "Release Date", value: details.releaseDate)
            Divider()
            InfoRow(
                label: "Votes",
                value: "\(details.voteCount.formatted()) ratings"
            )

            if let budget = details.formattedBudget {
                Divider()
                InfoRow(label: "Budget", value: budget)
            }

            if let revenue = details.formattedRevenue {
                Divider()
                InfoRow(label: "Revenue", value: revenue)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct InfoRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 16)
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct Section<Content: View>: View {

    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            content()
        }
    }
}

// MARK: - Skeleton

private struct DetailsSkeleton: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 70, height: 26)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 18)

                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                }

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 200, height: 14)
            }

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(height: 220)
        }
        .shimmering()
    }
}

// MARK: - Inline Error

private struct InlineErrorView: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Dismiss Button

private struct DismissButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(.white.opacity(0.15), lineWidth: 0.5))
        }
        .padding(.leading, 16)
        .padding(.top, 8)
        .accessibilityLabel("Back")
    }
}
