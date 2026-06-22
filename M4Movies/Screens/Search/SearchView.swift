import SwiftUI

struct SearchView: View {

    @State private var viewModel = SearchViewModel()
    @State private var query = ""
    @State private var path = NavigationPath()
    @Namespace private var transitionNamespace

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Search")
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailsView(movie: movie)
                        .navigationTransition(.zoom(sourceID: movie.id, in: transitionNamespace))
                }
        }
        .searchable(
            text: $query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search movies"
        )
        .onChange(of: query) { _, newValue in
            viewModel.onQueryChange(newValue)
        }
        .task {
            await viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.phase {
        case .idle:
            idleContent
        case .loading:
            MovieGridSkeleton(columns: columns)
        case .results:
            resultsGrid
        case .noResults:
            ContentUnavailableView.search(text: query)
        case .error(let message):
            ErrorState(message: message) {
                Task { await viewModel.retry() }
            }
        }
    }

    private var idleContent: some View {
        ScrollView {
            LazyVStack(spacing: 28) {
                if !viewModel.recentSearches.isEmpty {
                    RecentSearchesSection(
                        recents: viewModel.recentSearches,
                        onSelect: { recent in query = recent.keyword },
                        onRemove: { viewModel.removeRecent($0) },
                        onClearAll: { viewModel.clearAllRecents() }
                    )
                }

                if viewModel.isLoadingRecommendations &&
                    viewModel.popularMovies.isEmpty &&
                    viewModel.topRatedMovies.isEmpty {
                    SearchRecommendationSkeletons()
                } else {
                    SearchMovieSection(
                        title: "Popular",
                        movies: viewModel.popularMovies,
                        onSelect: { path.append($0) }
                    )

                    SearchMovieSection(
                        title: "Top Rated",
                        movies: viewModel.topRatedMovies,
                        onSelect: { path.append($0) }
                    )
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private var resultsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.movies) { movie in
                    Button {
                        viewModel.recordResultOpened()
                        path.append(movie)
                    } label: {
                        MovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: movie.id, in: transitionNamespace)
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(currentItem: movie) }
                    }
                }

                if viewModel.isLoadingMore {
                    ForEach(0..<4, id: \.self) { _ in
                        MovieCardSkeleton()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoadingMore)

            LoadMoreFooter(
                errorMessage: viewModel.loadMoreError,
                hasMorePages: viewModel.hasMorePages,
                onRetry: { Task { await viewModel.retryLoadMore() } }
            )
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

// MARK: - Recent Searches

private struct RecentSearchesSection: View {

    let recents: [RecentSearch]
    let onSelect: (RecentSearch) -> Void
    let onRemove: (RecentSearch) -> Void
    let onClearAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Searches")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button("Clear All", action: onClearAll)
                    .font(.footnote.weight(.medium))
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recents) { recent in
                        RecentSearchChip(
                            keyword: recent.keyword,
                            onTap: { onSelect(recent) },
                            onRemove: { onRemove(recent) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RecentSearchChip: View {

    let keyword: String
    let onTap: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onTap) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(keyword)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .padding(2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(keyword)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

// MARK: - Recommendations

private struct SearchMovieSection: View {

    let title: String
    let movies: [Movie]
    let onSelect: (Movie) -> Void

    private let cardWidth: CGFloat = 154

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.title2.bold())
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(movies) { movie in
                            Button {
                                onSelect(movie)
                            } label: {
                                MovieCard(movie: movie)
                                    .frame(width: cardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollClipDisabled()
            }
        }
    }
}

private struct SearchRecommendationSkeletons: View {

    var body: some View {
        VStack(spacing: 28) {
            ForEach(["Popular", "Top Rated"], id: \.self) { title in
                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(.title2.bold())
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(0..<4, id: \.self) { _ in
                                MovieCardSkeleton()
                                    .frame(width: 154)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .scrollDisabled(true)
                    .scrollClipDisabled()
                }
            }
        }
    }
}

// MARK: - Error State

private struct ErrorState: View {

    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchView()
}
