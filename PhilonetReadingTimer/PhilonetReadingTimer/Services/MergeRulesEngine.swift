import Foundation

/// Engine that handles conflicts between memory and disk reading times
class MergeRulesEngine: ObservableObject {
    @Published var conflicts: [ReadingTimeConflict] = []
    @Published var mergeHistory: [MergeResult] = []
    
    /// Applies merge rules when memory and disk times disagree
    /// - Parameters:
    ///   - articleId: The article ID
    ///   - memoryTime: Reading time from memory
    ///   - diskTime: Reading time from disk
    ///   - lastDiskSync: Last time disk was synced
    /// - Returns: The resolved reading time and merge rule used
    func resolveMerge(
        articleId: UUID,
        memoryTime: TimeInterval,
        diskTime: TimeInterval,
        lastDiskSync: Date
    ) -> (time: TimeInterval, rule: String, merged: Bool) {
        // Rule 1: Time should never go backward
        if memoryTime < diskTime {
            let conflict = ReadingTimeConflict(
                articleId: articleId,
                memoryTime: memoryTime,
                diskTime: diskTime,
                reason: "Time going backward detected"
            )
            addConflict(conflict)
            
            let result = MergeResult(
                articleId: articleId,
                previousDiskTime: diskTime,
                newDiskTime: diskTime,
                mergeRuleApplied: "Rule 1: Prevent backward time"
            )
            mergeHistory.append(result)
            
            return (diskTime, "Rule 1: Prevent backward time", true)
        }
        
        // Rule 2: Detect and prevent double counting
        // If time jumped by more than 10x what we'd expect in a reasonable session
        let timeDifference = memoryTime - diskTime
        let daysSinceDiskSync = Date().timeIntervalSince(lastDiskSync) / (24 * 3600)
        let expectedMaxDailyReading: TimeInterval = 12 * 3600  // 12 hours max per day
        let expectedMaxIncrease = expectedMaxDailyReading * daysSinceDiskSync
        
        if timeDifference > expectedMaxIncrease && timeDifference > 3600 {
            // Likely double counting - use disk time and flag it
            let conflict = ReadingTimeConflict(
                articleId: articleId,
                memoryTime: memoryTime,
                diskTime: diskTime,
                reason: "Likely double counting detected - unusual jump"
            )
            addConflict(conflict)
            
            // Add only 80% of the difference as a conservative approach
            let conservativeTime = diskTime + (timeDifference * 0.8)
            let result = MergeResult(
                articleId: articleId,
                previousDiskTime: diskTime,
                newDiskTime: conservativeTime,
                mergeRuleApplied: "Rule 2: Prevent double counting (conservative merge)"
            )
            mergeHistory.append(result)
            
            return (conservativeTime, "Rule 2: Prevent double counting", true)
        }
        
        // Rule 3: Normal case - trust memory if it's reasonable
        let result = MergeResult(
            articleId: articleId,
            previousDiskTime: diskTime,
            newDiskTime: memoryTime,
            mergeRuleApplied: "Rule 3: Accept memory time"
        )
        mergeHistory.append(result)
        
        return (memoryTime, "Rule 3: Accept memory time", true)
    }
    
    /// Checks if a crash is likely (memory and disk times differ significantly)
    func detectLikelyCrash(memoryTime: TimeInterval, diskTime: TimeInterval) -> Bool {
        let difference = abs(memoryTime - diskTime)
        // If difference is more than 30 seconds, likely a crash occurred
        return difference > 30
    }
    
    private func addConflict(_ conflict: ReadingTimeConflict) {
        // Keep last 100 conflicts
        conflicts.insert(conflict, at: 0)
        if conflicts.count > 100 {
            conflicts.removeLast()
        }
    }
    
    func clearHistory() {
        conflicts.removeAll()
        mergeHistory.removeAll()
    }
}
