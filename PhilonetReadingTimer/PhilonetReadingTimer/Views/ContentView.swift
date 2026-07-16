import SwiftUI

struct ContentView: View {
    @StateObject private var persistenceService = PersistenceService.shared
    @State private var showingDebugPanel = false
    
    var body: some View {
        NavigationView {
            List {
                if persistenceService.articles.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "book.open.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("No Articles Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Share an article from Safari using the share button to get started")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(persistenceService.articles) { article in
                        NavigationLink(destination: ArticleReaderView(article: article)) {
                            ArticleListItemView(article: article)
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let article = persistenceService.articles[index]
                            persistenceService.deleteArticle(id: article.id)
                        }
                    }
                }
            }
            .navigationTitle("My Articles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDebugPanel = true }) {
                        Image(systemName: "ladybug.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            .sheet(isPresented: $showingDebugPanel) {
                DebugPanelView()
            }
        }
    }
}

struct ArticleListItemView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = article.title {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
            }
            
            HStack {
                Text(article.url.host() ?? article.url.absoluteString)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(article.formattedReadingTime())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
