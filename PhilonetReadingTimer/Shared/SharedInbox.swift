import Foundation

/// Hand-off queue between the Share Extension and the main app.
///
/// App extensions cannot call `UIApplication.shared.open`, so the extension
/// writes shared URLs into an App Group container and the main app drains
/// them whenever it becomes active.
enum SharedInbox {
    /// Must match the App Group configured in both targets' entitlements.
    static let appGroupID = "group.com.philonet.readingtimer"

    private static let pendingKey = "pendingSharedURLs"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    /// Adds a URL to the pending queue (called from the Share Extension).
    static func enqueue(_ url: URL) {
        var pending = defaults.stringArray(forKey: pendingKey) ?? []
        pending.append(url.absoluteString)
        defaults.set(pending, forKey: pendingKey)
    }

    /// Returns and clears all pending URLs (called from the main app).
    static func drain() -> [URL] {
        let pending = defaults.stringArray(forKey: pendingKey) ?? []
        guard !pending.isEmpty else { return [] }
        defaults.removeObject(forKey: pendingKey)
        return pending.compactMap(URL.init(string:))
    }
}
