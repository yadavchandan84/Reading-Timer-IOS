import XCTest
@testable import PhilonetReadingTimer

class MergeRulesEngineTests: XCTestCase {
    var mergeEngine: MergeRulesEngine!
    
    override func setUp() {
        super.setUp()
        mergeEngine = MergeRulesEngine()
    }
    
    override func tearDown() {
        super.tearDown()
        mergeEngine = nil
    }
    
    // MARK: - Rule 1: Prevent Backward Time
    
    func testRule1_RejectBackwardTime() {
        let articleId = UUID()
        let memoryTime: TimeInterval = 300  // 5 minutes
        let diskTime: TimeInterval = 600    // 10 minutes
        
        let (resolvedTime, rule, _) = mergeEngine.resolveMerge(
            articleId: articleId,
            memoryTime: memoryTime,
            diskTime: diskTime,
            lastDiskSync: Date()
        )
        
        XCTAssertEqual(resolvedTime, diskTime, "Should keep disk time when memory is less")
        XCTAssertTrue(rule.contains("Prevent backward time"))
    }
    
    // MARK: - Rule 2: Prevent Double Counting
    
    func testRule2_DetectDoubleCounting() {
        let articleId = UUID()
        let memoryTime: TimeInterval = 50000  // ~13.8 hours
        let diskTime: TimeInterval = 5000     // ~1.4 hours
        let daysSinceSync = Date()
        
        let (resolvedTime, rule, _) = mergeEngine.resolveMerge(
            articleId: articleId,
            memoryTime: memoryTime,
            diskTime: diskTime,
            lastDiskSync: daysSinceSync
        )
        
        XCTAssertTrue(rule.contains("double counting"), "Should detect double counting")
        XCTAssertLessThan(resolvedTime, memoryTime, "Should apply conservative merge")
    }
    
    // MARK: - Rule 3: Accept Memory Time
    
    func testRule3_AcceptNormalMemoryTime() {
        let articleId = UUID()
        let memoryTime: TimeInterval = 1200  // 20 minutes
        let diskTime: TimeInterval = 1000    // ~16.7 minutes
        
        let (resolvedTime, rule, _) = mergeEngine.resolveMerge(
            articleId: articleId,
            memoryTime: memoryTime,
            diskTime: diskTime,
            lastDiskSync: Date()
        )
        
        XCTAssertEqual(resolvedTime, memoryTime, "Should accept memory time")
        XCTAssertTrue(rule.contains("Accept memory time"))
    }
    
    // MARK: - Crash Detection
    
    func testCrashDetection_LargeTimeDifference() {
        let isCrash = mergeEngine.detectLikelyCrash(memoryTime: 1000, diskTime: 500)
        XCTAssertTrue(isCrash, "Should detect crash with >30s difference")
    }
    
    func testCrashDetection_SmallTimeDifference() {
        // 20s difference is below the 30s threshold
        let isCrash = mergeEngine.detectLikelyCrash(memoryTime: 100, diskTime: 80)
        XCTAssertFalse(isCrash, "Should not detect crash with <30s difference")
    }
    
    // MARK: - History Tracking
    
    func testHistoryTracking() {
        let articleId = UUID()
        let initialCount = mergeEngine.mergeHistory.count
        
        mergeEngine.resolveMerge(
            articleId: articleId,
            memoryTime: 1200,
            diskTime: 1000,
            lastDiskSync: Date()
        )
        
        XCTAssertEqual(mergeEngine.mergeHistory.count, initialCount + 1, "Should track merge")
        XCTAssertEqual(mergeEngine.mergeHistory.last?.articleId, articleId)
    }
}

class PersistenceServiceTests: XCTestCase {
    var persistenceService: PersistenceService!
    var fileURL: URL!
    
    override func setUp() {
        super.setUp()
        // Isolated file so tests never touch the app's real data.
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("articles-\(UUID().uuidString).json")
        persistenceService = PersistenceService(fileURL: fileURL)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: fileURL)
        persistenceService = nil
        super.tearDown()
    }
    
    func testAddArticle() {
        let url = URL(string: "https://example.com/article")!
        let initialCount = persistenceService.articles.count
        
        persistenceService.addArticle(url: url, title: "Test Article")
        
        XCTAssertEqual(persistenceService.articles.count, initialCount + 1)
        XCTAssertEqual(persistenceService.articles.first?.url, url)
    }
    
    func testUpdateArticleReadingTime() {
        let url = URL(string: "https://example.com/article")!
        persistenceService.addArticle(url: url)
        
        let articleId = persistenceService.articles.first!.id
        persistenceService.updateArticleReadingTime(articleId: articleId, readingTime: 1500)
        
        XCTAssertEqual(persistenceService.articles.first?.totalReadingTime, 1500)
    }
    
    func testDeleteArticle() {
        let url = URL(string: "https://example.com/article")!
        persistenceService.addArticle(url: url)
        
        let articleId = persistenceService.articles.first!.id
        persistenceService.deleteArticle(id: articleId)
        
        XCTAssertEqual(persistenceService.articles.count, 0)
    }
    
    func testFormattedReadingTime() {
        let article = Article(
            url: URL(string: "https://example.com")!,
            title: "Test"
        )
        
        XCTAssertEqual(article.formattedReadingTime(), "0s")
        
        var article2 = Article(
            url: URL(string: "https://example.com")!,
            title: "Test"
        )
        article2.totalReadingTime = 3661  // 1h 1m 1s
        
        XCTAssertTrue(article2.formattedReadingTime().contains("1h"))
    }
}
