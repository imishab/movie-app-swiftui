import SwiftUI

struct LoadMoreFooter: View {

    let errorMessage: String?
    let hasMorePages: Bool
    let onRetry: () -> Void

    var body: some View {
        Group {
            if let errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Retry", action: onRetry)
                        .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else if !hasMorePages {
                Text("You've reached the end")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
    }
}
