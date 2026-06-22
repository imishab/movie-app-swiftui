import SwiftUI

struct MovieGridSkeleton: View {

    let columns: [GridItem]
    var count: Int = 8

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<count, id: \.self) { _ in
                    MovieCardSkeleton()
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading movies")
    }
}
