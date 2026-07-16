import Foundation

/// Represents a saved article for reading
struct Article: Identifiable, Codable, Equatable {
    let id: UUID
    let url: URL
    let title: String?
    let addedDate: Date
    var totalReadingTime: TimeInterval = 0  // in seconds
    var lastReadDate: Date?
    
    // Memory-based reading time (can differ from disk)
    var memoryReadingTime: TimeInterval?
    
    enum CodingKeys: String, CodingKey {
        case id, url, title, addedDate, totalReadingTime, lastReadDate
    }
    
    init(id: UUID = UUID(), url: URL, title: String? = nil, addedDate: Date = Date()) {
        self.id = id
        self.url = url
        self.title = title
        self.addedDate = addedDate
    }
    
    // Format reading time for display
    func formattedReadingTime() -> String {
        let hours = Int(totalReadingTime) / 3600
        let minutes = (Int(totalReadingTime) % 3600) / 60
        let seconds = Int(totalReadingTime) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

/// Represents a reading session for an article
struct ReadingSession: Identifiable, Codable {
    let id: UUID
    let articleId: UUID
    let startTime: Date
    var endTime: Date?
    var accumulatedTime: TimeInterval = 0  // in seconds
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return accumulatedTime + (end.timeIntervalSince(startTime))
    }
    
    init(articleId: UUID) {
        self.id = UUID()
        self.articleId = articleId
        self.startTime = Date()
    }
}

/// Represents a conflict between memory and disk reading times
struct ReadingTimeConflict: Identifiable {
    let id: UUID = UUID()
    let articleId: UUID
    let memoryTime: TimeInterval
    let diskTime: TimeInterval
    let detectedAt: Date = Date()
    let reason: String
    
    var timeDifference: TimeInterval {
        abs(memoryTime - diskTime)
    }
}

/// Result of applying merge rules
struct MergeResult: Identifiable {
    let id: UUID = UUID()
    let articleId: UUID
    let previousDiskTime: TimeInterval
    let newDiskTime: TimeInterval
    let mergeRuleApplied: String
    let timestamp: Date = Date()
    
    var timeDelta: TimeInterval {
        newDiskTime - previousDiskTime
    }
}
