import Foundation

final class PersistenceService: ObservableObject {
    static let shared = PersistenceService()

    @Published var articles: [Article] = []
    let mergeRulesEngine = MergeRulesEngine()

    private let articlesFileURL: URL

    /// - Parameter fileURL: Override the storage location (used by tests).
    init(fileURL: URL? = nil) {
        if let fileURL = fileURL {
            articlesFileURL = fileURL
        } else {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            articlesFileURL = documents.appendingPathComponent("articles.json")
        }
        loadArticles()
    }

    // MARK: - Articles Management

    /// Loads synchronously so callers never race against a late async overwrite.
    func loadArticles() {
        guard FileManager.default.fileExists(atPath: articlesFileURL.path) else {
            articles = []
            return
        }
        do {
            let data = try Data(contentsOf: articlesFileURL)
            let decoded = try JSONDecoder().decode([Article].self, from: data)
            articles = decoded.sorted { $0.addedDate > $1.addedDate }
        } catch {
            print("Error loading articles: \(error)")
            articles = []
        }
    }

    func saveArticles() {
        do {
            let data = try JSONEncoder().encode(articles)
            try data.write(to: articlesFileURL, options: .atomic)
        } catch {
            print("Error saving articles: \(error)")
        }
    }

    func addArticle(url: URL, title: String? = nil) {
        // Avoid duplicates when the same link is shared twice.
        guard !articles.contains(where: { $0.url == url }) else { return }
        let article = Article(url: url, title: title ?? url.extractTitle())
        articles.insert(article, at: 0)
        saveArticles()
    }

    /// Imports URLs queued by the Share Extension.
    func importPendingSharedArticles() {
        for url in SharedInbox.drain() {
            addArticle(url: url)
        }
    }

    func updateArticleReadingTime(articleId: UUID, readingTime: TimeInterval) {
        guard let index = articles.firstIndex(where: { $0.id == articleId }) else { return }
        articles[index].totalReadingTime = readingTime
        articles[index].lastReadDate = Date()
        articles[index].memoryReadingTime = readingTime
        saveArticles()
    }

    func deleteArticle(id: UUID) {
        articles.removeAll { $0.id == id }
        saveArticles()
    }

    func getArticle(id: UUID) -> Article? {
        articles.first { $0.id == id }
    }

    // MARK: - Merge Conflict Resolution

    /// Writes the in-memory reading time to disk, resolving conflicts with the merge rules.
    func syncReadingTimeWithMergeRules(articleId: UUID, memoryTime: TimeInterval) {
        guard let index = articles.firstIndex(where: { $0.id == articleId }) else { return }

        let diskTime = articles[index].totalReadingTime
        let lastSyncDate = articles[index].lastReadDate ?? articles[index].addedDate

        let resolution = mergeRulesEngine.resolveMerge(
            articleId: articleId,
            memoryTime: memoryTime,
            diskTime: diskTime,
            lastDiskSync: lastSyncDate
        )
        DebugLogger.logMerge(articleId: articleId, oldTime: diskTime, newTime: resolution.time, rule: resolution.rule)

        articles[index].totalReadingTime = resolution.time
        articles[index].memoryReadingTime = memoryTime
        articles[index].lastReadDate = Date()
        saveArticles()
    }

    func getMergeRulesEngine() -> MergeRulesEngine {
        mergeRulesEngine
    }
}
