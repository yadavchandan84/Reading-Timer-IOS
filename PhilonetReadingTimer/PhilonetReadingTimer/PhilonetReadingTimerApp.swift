import SwiftUI
import WebKit

@main
struct PhilonetReadingTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Request notification permissions if needed
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // Handle URLs from Share Extension
        if url.scheme == "philonet-open" {
            if let host = url.host, let urlToOpen = URL(string: host) {
                DispatchQueue.main.async {
                    PersistenceService.shared.addArticle(url: urlToOpen)
                }
            }
        }
        return true
    }
}

// Enable WebKit for loading web content
extension WKWebView {
    override open var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
