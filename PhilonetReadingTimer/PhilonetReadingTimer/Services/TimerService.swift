import Foundation
import UIKit

final class TimerService: ObservableObject {
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning = false

    private var timer: Timer?
    private var sessionStartTime: Date?
    /// Time accumulated before the current running segment (disk time + earlier segments).
    private var accumulatedTime: TimeInterval = 0
    private var currentArticleId: UUID?
    private let persistenceService: PersistenceService
    private var observers: [NSObjectProtocol] = []

    init(persistenceService: PersistenceService = .shared) {
        self.persistenceService = persistenceService
        setupLifecycleObservers()
    }

    private func setupLifecycleObservers() {
        let center = NotificationCenter.default
        // Pause (and persist) whenever the app leaves the foreground so no ghost time is counted.
        for name in [UIApplication.didEnterBackgroundNotification, UIApplication.willTerminateNotification] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.pauseTimer()
            })
        }
        // Resume is intentionally manual when returning to the foreground.
    }

    func startTimer(articleId: UUID, initialTime: TimeInterval = 0) {
        // onAppear can fire more than once; don't restart an active session.
        if currentArticleId == articleId && isRunning { return }
        if currentArticleId != articleId {
            currentArticleId = articleId
            accumulatedTime = initialTime
            elapsedTime = initialTime
        }
        startTicking()
    }

    func pauseTimer() {
        guard isRunning else { return }
        updateTimer()
        accumulatedTime = elapsedTime   // keep progress so Resume continues from here
        sessionStartTime = nil
        isRunning = false
        timer?.invalidate()
        timer = nil

        if let articleId = currentArticleId {
            persistenceService.syncReadingTimeWithMergeRules(articleId: articleId, memoryTime: elapsedTime)
            DebugLogger.logTimerEvent(event: "Paused", articleId: articleId, currentTime: elapsedTime)
        }
    }

    func resumeTimer() {
        guard !isRunning, currentArticleId != nil else { return }
        startTicking()
    }

    func stopTimer() {
        pauseTimer()
        elapsedTime = 0
        accumulatedTime = 0
        currentArticleId = nil
    }

    private func startTicking() {
        sessionStartTime = Date()
        isRunning = true
        timer?.invalidate()
        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        // .common keeps the timer firing while the user scrolls the web view.
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    private func updateTimer() {
        guard let sessionStart = sessionStartTime else { return }
        elapsedTime = accumulatedTime + Date().timeIntervalSince(sessionStart)
    }

    func getFormattedTime() -> String {
        let total = Int(elapsedTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        timer?.invalidate()
    }
}
