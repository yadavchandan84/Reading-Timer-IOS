import SwiftUI

@main
struct PhilonetReadingTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let persistenceService = PersistenceService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear { persistenceService.importPendingSharedArticles() }
                // Custom URL scheme: philonet-open://add?url=<percent-encoded URL>
                // (With the SwiftUI lifecycle, AppDelegate's open-URL callback is
                // never called, so URLs must be handled here.)
                .onOpenURL { url in
                    if let articleURL = Self.articleURL(from: url) {
                        persistenceService.addArticle(url: articleURL)
                    }
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                // Pick up anything saved by the Share Extension.
                persistenceService.importPendingSharedArticles()
            }
        }
    }

    static func articleURL(from url: URL) -> URL? {
        guard url.scheme == "philonet-open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let value = components.queryItems?.first(where: { $0.name == "url" })?.value,
              let articleURL = URL(string: value),
              articleURL.scheme == "http" || articleURL.scheme == "https"
        else { return nil }
        return articleURL
    }
}
