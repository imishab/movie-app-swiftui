import SwiftUI

struct CategoryMoviesView: View {

    let category: MovieCategory

    @State private var viewModel: CategoryMoviesViewModel
    @Namespace private var transitionNamespace

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(category: MovieCategory) {
        self.category = category
        _viewModel = State(initialValue: CategoryMoviesViewModel(category: category))
    }

    var body: some View {
        ScrollView {
            Group {
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    skeletonGrid
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.movies.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task { await viewModel.retry() }
                    }
                    .frame(minHeight: 420)
                } else {
                    movieGrid
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.visible, for: .navigationBar)
        .navigationDestination(for: Movie.self) { movie in
            MovieDetailsView(movie: movie)
                .navigationTransition(
                    .zoom(sourceID: movie.id, in: transitionNamespace)
                )
        }
        .task {
            await viewModel.loadMovies()
        }
    }

    private var movieGrid: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: movie) {
                        MovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(
                        id: movie.id,
                        in: transitionNamespace
                    )
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

            LoadMoreFooter(
                errorMessage: viewModel.loadMoreError,
                hasMorePages: viewModel.hasMorePages,
                onRetry: { Task { await viewModel.retryLoadMore() } }
            )
        }
    }

    private var skeletonGrid: some View {
        LazyVGrid(columns: columns, spacing: 18) {
            ForEach(0..<8, id: \.self) { _ in
                MovieCardSkeleton()
            }
        }
    }
}

@MainActor
@Observable
private final class CategoryMoviesViewModel {

    let category: MovieCategory

    var movies: [Movie] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var loadMoreError: String?

    private let repository: MovieRepository
    private var currentPage = 0
    private var totalPages = 1
    private var prefetchTriggerID: Movie.ID?

    private let prefetchOffset = 5

    init(
        category: MovieCategory,
        repository: MovieRepository = MovieRepositoryImpl()
    ) {
        self.category = category
        self.repository = repository
    }

    var hasMorePages: Bool {
        currentPage < totalPages
    }

    func loadMovies() async {
        guard movies.isEmpty else { return }
        isLoading = true
        await fetchInitialPage()
        isLoading = false
    }

    func retry() async {
        errorMessage = nil
        isLoading = true
        await fetchInitialPage()
        isLoading = false
    }

    func loadMoreIfNeeded(currentItem: Movie) async {
        guard currentItem.id == prefetchTriggerID,
              !isLoadingMore,
              !isLoading,
              hasMorePages,
              loadMoreError == nil
        else { return }

        await fetchNextPage()
    }

    func retryLoadMore() async {
        loadMoreError = nil
        await fetchNextPage()
    }

    private func fetchInitialPage() async {
        do {
            let result = try await repository.fetchMovies(category: category, page: 1)
            movies = result.movies
            currentPage = result.page
            totalPages = result.totalPages
            errorMessage = nil
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            if Task.isCancelled { return }
            errorMessage = "Failed to load \(category.title.lowercased()) movies."
        }
    }

    private func fetchNextPage() async {
        guard hasMorePages else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let result = try await repository.fetchMovies(
                category: category,
                page: currentPage + 1
            )
            movies.append(contentsOf: result.movies)
            currentPage = result.page
            totalPages = result.totalPages
            loadMoreError = nil
            updatePrefetchTrigger()
        } catch {
            if Task.isCancelled { return }
            loadMoreError = "Couldn't load more. Tap to retry."
        }
    }

    private func updatePrefetchTrigger() {
        let triggerIndex = max(0, movies.count - prefetchOffset)
        prefetchTriggerID = movies.indices.contains(triggerIndex)
            ? movies[triggerIndex].id
            : nil
    }
}
