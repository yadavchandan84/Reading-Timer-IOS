import SwiftUI

struct ContentView: View {
    @ObservedObject private var persistenceService = PersistenceService.shared
    @State private var showingDebugPanel = false
    @State private var showingAddSheet = false
    @State private var newArticleURL = ""

    var body: some View {
        NavigationView {
            List {
                if persistenceService.articles.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                            .accessibilityHidden(true)

                        Text("No Articles Yet")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("Share an article from Safari, or tap + to add a link")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(persistenceService.articles) { article in
                        NavigationLink(destination: ArticleReaderView(article: article)) {
                            ArticleListItemView(article: article)
                        }
                    }
                    .onDelete { indices in
                        let ids = indices.map { persistenceService.articles[$0].id }
                        ids.forEach { persistenceService.deleteArticle(id: $0) }
                    }
                }
            }
            .navigationTitle("My Articles")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingDebugPanel = true }) {
                        Image(systemName: "ladybug.fill")
                            .foregroundColor(.orange)
                    }
                    .accessibilityLabel("Debug panel")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        newArticleURL = ""
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add article")
                }
            }
            .sheet(isPresented: $showingDebugPanel) {
                DebugPanelView()
            }
            .sheet(isPresented: $showingAddSheet) {
                AddArticleView(urlText: $newArticleURL) { url in
                    persistenceService.addArticle(url: url)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

/// Simple form for adding an article by URL (handy on the simulator).
struct AddArticleView: View {
    @Binding var urlText: String
    let onAdd: (URL) -> Void
    @Environment(\.dismiss) private var dismiss

    private var parsedURL: URL? {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        let withScheme = trimmed.contains("://") ? trimmed : "https://" + trimmed
        guard let url = URL(string: withScheme),
              url.scheme == "http" || url.scheme == "https",
              url.host != nil
        else { return nil }
        return url
    }

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Example: https://www.apple.com/newsroom")) {
                    TextField("Article URL", text: $urlText)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Add Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let url = parsedURL { onAdd(url) }
                        dismiss()
                    }
                    .disabled(parsedURL == nil)
                }
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
                Text(article.url.host ?? article.url.absoluteString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)

                    Text(article.formattedReadingTime())
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Reading time \(article.formattedReadingTime())")
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
