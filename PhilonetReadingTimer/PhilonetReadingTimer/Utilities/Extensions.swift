import Foundation
import UserNotifications

// MARK: - Extension for Date Formatting
extension Date {
    func formatForDisplay() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Extension for URL Utilities
extension URL {
    func extractTitle() -> String? {
        return self.host?.replacingOccurrences(of: "www.", with: "")
    }
}

// MARK: - Notification Helper
struct NotificationHelper {
    static func sendReadingCompleteNotification(article: Article, readingTime: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Reading Complete"
        var finished = article
        finished.totalReadingTime = readingTime
        content.body = "You spent \(finished.formattedReadingTime()) reading \(article.title ?? article.url.host ?? "an article")"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}

// MARK: - Debug Logging
struct DebugLogger {
    static func logMerge(articleId: UUID, oldTime: TimeInterval, newTime: TimeInterval, rule: String) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let timestamp = formatter.string(from: Date())
        
        let logMessage = """
        [MERGE] \(timestamp)
        Article ID: \(articleId)
        Previous Time: \(oldTime)s
        New Time: \(newTime)s
        Rule Applied: \(rule)
        """
        
        print(logMessage)
    }
    
    static func logTimerEvent(event: String, articleId: UUID, currentTime: TimeInterval) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let timestamp = formatter.string(from: Date())
        
        print("[TIMER] \(timestamp) - \(event) for article \(articleId): \(currentTime)s")
    }
}
