import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var isProfilePresented = false
    @Namespace private var transitionNamespace

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(spacing: 28) {
                        Color.clear
                            .frame(height: 50)

                        if !viewModel.featuredMovies.isEmpty {
                            HomeHeroSlider(
                                movies: viewModel.featuredMovies,
                                transitionNamespace: transitionNamespace
                            )
                        }

                        if viewModel.isLoading && !hasSectionContent {
                            sectionSkeletons
                        } else if let errorMessage = viewModel.errorMessage,
                                  !hasSectionContent {
                            ErrorView(message: errorMessage) {
                                Task { await viewModel.retry() }
                            }
                            .frame(minHeight: 320)
                        } else {
                            movieSections
                        }
                    }
                    .padding(.bottom, 36)
                }
                .refreshable {
                    await viewModel.refresh()
                }

                headerBackground
                titleHeader
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: HomeMovieRoute.self) { route in
                MovieDetailsView(movie: route.movie)
                    .navigationTransition(
                        .zoom(sourceID: route.sourceID, in: transitionNamespace)
                    )
            }
            .navigationDestination(for: MovieCategory.self) { category in
                CategoryMoviesView(category: category)
            }
        }
        .task {
            await viewModel.loadContent()
        }
        .alert(
            "Couldn't Refresh",
            isPresented: refreshErrorPresented,
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.refreshError ?? "") }
        )
        .sheet(isPresented: $isProfilePresented) {
            ProfileDrawer()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
        }
    }

    private var titleHeader: some View {
        HStack(spacing: 16) {
            Text("Movies")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button {
                isProfilePresented = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))

                    Image("UserAvatar")
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("User profile")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private var headerBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(0.96), location: 0),
                .init(color: .black.opacity(0.82), location: 0.42),
                .init(color: .black.opacity(0.42), location: 0.75),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 140)
        .allowsHitTesting(false)
        .ignoresSafeArea(edges: .top)
    }

    private var movieSections: some View {
        VStack(spacing: 30) {
            MovieSection(
                category: .topRated,
                movies: viewModel.topRatedMovies,
                transitionNamespace: transitionNamespace
            )

            MovieSection(
                category: .popular,
                movies: viewModel.popularMovies,
                transitionNamespace: transitionNamespace
            )

            Image("HomeBanner")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 16)
                .accessibilityLabel("Featured movie banner")

            MovieSection(
                category: .nowPlaying,
                movies: viewModel.nowPlayingMovies,
                transitionNamespace: transitionNamespace
            )
        }
    }

    private var sectionSkeletons: some View {
        VStack(spacing: 30) {
            ForEach(MovieCategory.homeSections) { category in
                MovieSectionSkeleton(title: category.title)
            }
        }
    }

    private var hasSectionContent: Bool {
        !viewModel.popularMovies.isEmpty ||
        !viewModel.nowPlayingMovies.isEmpty ||
        !viewModel.topRatedMovies.isEmpty
    }

    private var refreshErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.refreshError != nil },
            set: { if !$0 { viewModel.refreshError = nil } }
        )
    }
}

struct HomeMovieRoute: Hashable {
    let movie: Movie
    let sourceID: HomeMovieTransitionSource
}

enum HomeMovieTransitionSource: Hashable {
    case hero(Movie.ID)
    case section(MovieCategory, Movie.ID)
}

// MARK: - Profile Drawer

private struct ProfileDrawer: View {

    @Environment(\.dismiss) private var dismiss
    @State private var isLogoutConfirmationPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    accountOptions
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationDestination(for: ProfileDestination.self) { destination in
                switch destination {
                case .personalInformation:
                    PersonalInformationView()
                case .changePassword:
                    ChangePasswordView()
                }
            }
        }
        .confirmationDialog(
            "Log out of M4Movies?",
            isPresented: $isLogoutConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Log Out", role: .destructive) {
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can sign back in at any time.")
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.22),
                                Color.purple.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image("UserAvatar")
                    .resizable()
                    .scaledToFit()
                    .padding(7)
            }
            .frame(width: 76, height: 76)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Alex Morgan")
                    .font(.title3.bold())

                Text("alex.morgan@example.com")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.14),
                    Color(.secondarySystemGroupedBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.07), lineWidth: 1)
        }
    }

    private var accountOptions: some View {
        VStack(spacing: 0) {
            NavigationLink(value: ProfileDestination.personalInformation) {
                ProfileOptionRow(
                    title: "Personal Information",
                    systemImage: "person.crop.circle",
                    tint: .blue
                )
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 58)

            NavigationLink(value: ProfileDestination.changePassword) {
                ProfileOptionRow(
                    title: "Change Password",
                    systemImage: "lock.rotation",
                    tint: .orange
                )
            }
            .buttonStyle(.plain)

            Divider()
                .padding(.leading, 58)

            Button(role: .destructive) {
                isLogoutConfirmationPresented = true
            } label: {
                ProfileOptionRow(
                    title: "Log Out",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    tint: .red,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        }
    }
}

private enum ProfileDestination: Hashable {
    case personalInformation
    case changePassword
}

private struct ProfileOptionRow: View {

    let title: String
    let systemImage: String
    let tint: Color
    var showsChevron = true

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(title == "Log Out" ? Color.red : Color.primary)

            Spacer()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}

private struct PersonalInformationView: View {

    @State private var name = "Alex Morgan"
    @State private var email = "alex.morgan@example.com"

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $name)
                    .textContentType(.name)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }

            Section {
                Button("Save Changes") {}
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ChangePasswordView: View {

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmedPassword = ""

    var body: some View {
        Form {
            Section {
                SecureField("Current Password", text: $currentPassword)
                    .textContentType(.password)

                SecureField("New Password", text: $newPassword)
                    .textContentType(.newPassword)

                SecureField("Confirm New Password", text: $confirmedPassword)
                    .textContentType(.newPassword)
            } footer: {
                Text("Use at least 8 characters with a mix of letters and numbers.")
            }

            Section {
                Button("Update Password") {}
                    .frame(maxWidth: .infinity)
                    .disabled(
                        newPassword.count < 8 ||
                        newPassword != confirmedPassword ||
                        currentPassword.isEmpty
                    )
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct MovieSection: View {

    let category: MovieCategory
    let movies: [Movie]
    let transitionNamespace: Namespace.ID

    private let cardWidth: CGFloat = 154

    var body: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(movies) { movie in
                            let sourceID = HomeMovieTransitionSource.section(
                                category,
                                movie.id
                            )

                            NavigationLink(
                                value: HomeMovieRoute(
                                    movie: movie,
                                    sourceID: sourceID
                                )
                            ) {
                                MovieCard(movie: movie)
                                    .frame(width: cardWidth)
                            }
                            .buttonStyle(.plain)
                            .matchedTransitionSource(
                                id: sourceID,
                                in: transitionNamespace
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollClipDisabled()
            }
        }
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(category.title)
                .font(.title2.bold())

            Spacer()

            NavigationLink(value: category) {
                HStack(spacing: 4) {
                    Text("View More")
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct MovieSectionSkeleton: View {

    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.title2.bold())

                Spacer()

                Text("View More")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
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

private extension MovieCategory {

    static let homeSections: [MovieCategory] = [
        .topRated,
        .popular,
        .nowPlaying,
    ]
}

struct ErrorView: View {

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

            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
}
