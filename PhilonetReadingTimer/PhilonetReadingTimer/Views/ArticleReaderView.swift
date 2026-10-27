import SwiftUI
import WebKit

struct ArticleReaderView: View {
    let article: Article
    @StateObject private var timerService = TimerService()
    @State private var showDebugPanel = false
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // Timer Display
            VStack(spacing: 12) {
                Text("Reading Time")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(timerService.getFormattedTime())
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(timerService.isRunning ? .blue : .secondary)
                    .accessibilityLabel("Reading time \(timerService.getFormattedTime())")

                HStack(spacing: 20) {
                    Button(action: { timerService.pauseTimer() }) {
                        Label("Pause", systemImage: "pause.fill")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(timerService.isRunning ? Color.orange : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!timerService.isRunning)

                    Button(action: { timerService.resumeTimer() }) {
                        Label("Resume", systemImage: "play.fill")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(timerService.isRunning ? Color.gray : Color.green)
                            .cornerRadius(8)
                    }
                    .disabled(timerService.isRunning)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()

            // Web View
            ZStack {
                WebViewContainer(url: article.url, isLoading: $isLoading)
                if isLoading {
                    ProgressView("Loading…")
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationTitle(article.title ?? article.url.host ?? "Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showDebugPanel = true }) {
                    Image(systemName: "ladybug.fill")
                        .foregroundColor(.orange)
                }
                .accessibilityLabel("Debug panel")
            }
        }
        .onAppear {
            timerService.startTimer(articleId: article.id, initialTime: article.totalReadingTime)
        }
        .onDisappear {
            timerService.pauseTimer()
        }
        .sheet(isPresented: $showDebugPanel) {
            DebugPanelView()
        }
    }
}

// MARK: - WebView Container

struct WebViewContainer: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

struct ArticleReaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArticleReaderView(article: Article(url: URL(string: "https://www.apple.com")!, title: "Apple"))
        }
    }
}
