import SwiftUI

struct SettingsView: View {

    @State private var showingClearConfirmation = false

    private let recentSearchRepository: RecentSearchRepository = RecentSearchRepositoryImpl()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(role: .destructive) {
                        showingClearConfirmation = true
                    } label: {
                        Label("Clear Search History", systemImage: "trash")
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
        }
        .confirmationDialog(
            "Clear Search History?",
            isPresented: $showingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear", role: .destructive) {
                try? recentSearchRepository.clearAll()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove all of your recent searches.")
        }
    }

    private var appVersion: String {
        let dict = Bundle.main.infoDictionary
        let version = dict?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = dict?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
}
