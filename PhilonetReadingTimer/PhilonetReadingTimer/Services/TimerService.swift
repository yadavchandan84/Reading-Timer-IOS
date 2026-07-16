import Foundation
import Combine

class TimerService: NSObject, ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var pausedTime: TimeInterval = 0
    private var currentArticleId: UUID?
    private let persistenceService = PersistenceService.shared
    
    override init() {
        super.init()
        setupLifecycleObservers()
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func startTimer(articleId: UUID, initialTime: TimeInterval = 0) {
        currentArticleId = articleId
        pausedTime = initialTime
        elapsedTime = initialTime
        sessionStartTime = Date()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        if let articleId = currentArticleId {
            persistenceService.updateArticleReadingTime(articleId: articleId, readingTime: elapsedTime)
        }
    }
    
    func resumeTimer() {
        if !isRunning && currentArticleId != nil {
            sessionStartTime = Date()
            isRunning = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        }
    }
    
    func stopTimer() {
        pauseTimer()
        elapsedTime = 0
        pausedTime = 0
        sessionStartTime = nil
        currentArticleId = nil
    }
    
    private func updateTimer() {
        guard let sessionStart = sessionStartTime else { return }
        let elapsed = Date().timeIntervalSince(sessionStart)
        elapsedTime = pausedTime + elapsed
    }
    
    @objc private func appDidEnterBackground() {
        if isRunning {
            pauseTimer()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // App will resume timer manually when user returns to article
        // This prevents ghost time counting
    }
    
    func getFormattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
}
