import SwiftUI

struct FavoritesView: View {

    @Environment(FavoritesStore.self) private var favoritesStore
    @Namespace private var transitionNamespace

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if favoritesStore.favorites.isEmpty {
                    EmptyState()
                } else {
                    grid
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailsView(movie: movie)
                    .navigationTransition(.zoom(sourceID: movie.id, in: transitionNamespace))
            }
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(favoritesStore.favorites) { movie in
                    NavigationLink(value: movie) {
                        FavoriteCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                    .matchedTransitionSource(id: movie.id, in: transitionNamespace)
                    .contextMenu {
                        Button(role: .destructive) {
                            favoritesStore.toggle(movie)
                        } label: {
                            Label("Remove from Favorites", systemImage: "heart.slash")
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .animation(.easeInOut(duration: 0.25), value: favoritesStore.favorites)
        }
    }
}

// MARK: - Favorite Card

private struct FavoriteCard: View {

    let movie: Movie

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MovieCard(movie: movie)

            FavoriteBadge()
                .padding(8)
        }
    }
}

private struct FavoriteBadge: View {

    var body: some View {
        Image(systemName: "heart.fill")
            .font(.callout.weight(.bold))
            .foregroundStyle(.white)
            .padding(7)
            .background(Color.red.opacity(0.9), in: Circle())
            .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
            .accessibilityHidden(true)
    }
}

// MARK: - Empty State

private struct EmptyState: View {

    var body: some View {
        ContentUnavailableView(
            "No Favorites Yet",
            systemImage: "heart",
            description: Text("Tap the heart on a movie's detail page to add it here.")
        )
    }
}

#Preview {
    FavoritesView()
        .environment(FavoritesStore())
}
