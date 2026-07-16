import SwiftUI
import WebKit

struct ArticleReaderView: View {
    let article: Article
    @StateObject private var timerService = TimerService()
    @State private var showDebugPanel = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                // Timer Display
                VStack(spacing: 12) {
                    Text("Reading Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(timerService.getFormattedTime())
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 20) {
                        Button(action: timerService.pauseTimer) {
                            Label("Pause", systemImage: "pause.fill")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                        
                        Button(action: timerService.resumeTimer) {
                            Label("Resume", systemImage: "play.fill")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Web View
                WebViewContainer(url: article.url)
                    .ignoresSafeArea(edges: .bottom)
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: { showDebugPanel = true }) {
                        Image(systemName: "ladybug.fill")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
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
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    ArticleReaderView(article: Article(url: URL(string: "https://www.apple.com")!, title: "Apple"))
}
