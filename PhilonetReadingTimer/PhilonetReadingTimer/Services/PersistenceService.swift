import Foundation

class PersistenceService: ObservableObject {
    static let shared = PersistenceService()
    
    @Published var articles: [Article] = []
    private let articlesFileName = "articles.json"
    private let mergeRulesEngine = MergeRulesEngine()
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var articlesFileURL: URL {
        documentsDirectory.appendingPathComponent(articlesFileName)
    }
    
    init() {
        loadArticles()
    }
    
    // MARK: - Articles Management
    
    func loadArticles() {
        do {
            let data = try Data(contentsOf: articlesFileURL)
            let decoded = try JSONDecoder().decode([Article].self, from: data)
            DispatchQueue.main.async {
                self.articles = decoded.sorted { $0.addedDate > $1.addedDate }
            }
        } catch {
            print("Error loading articles: \(error)")
            DispatchQueue.main.async {
                self.articles = []
            }
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
        let article = Article(url: url, title: title)
        articles.insert(article, at: 0)
        saveArticles()
    }
    
    func updateArticleReadingTime(articleId: UUID, readingTime: TimeInterval) {
        if let index = articles.firstIndex(where: { $0.id == articleId }) {
            articles[index].totalReadingTime = readingTime
            articles[index].lastReadDate = Date()
            articles[index].memoryReadingTime = readingTime
            saveArticles()
        }
    }
    
    func deleteArticle(id: UUID) {
        articles.removeAll { $0.id == id }
        saveArticles()
    }
    
    func getArticle(id: UUID) -> Article? {
        return articles.first { $0.id == id }
    }
    
    // MARK: - Merge Conflict Resolution
    
    func syncReadingTimeWithMergeRules(articleId: UUID, memoryTime: TimeInterval) {
        guard let index = articles.firstIndex(where: { $0.id == articleId }) else { return }
        
        let diskTime = articles[index].totalReadingTime
        let lastSyncDate = articles[index].lastReadDate ?? articles[index].addedDate
        
        let (resolvedTime, rule, _) = mergeRulesEngine.resolveMerge(
            articleId: articleId,
            memoryTime: memoryTime,
            diskTime: diskTime,
            lastDiskSync: lastSyncDate
        )
        
        articles[index].totalReadingTime = resolvedTime
        articles[index].memoryReadingTime = memoryTime
        articles[index].lastReadDate = Date()
        saveArticles()
    }
    
    func getMergeRulesEngine() -> MergeRulesEngine {
        return mergeRulesEngine
    }
}
