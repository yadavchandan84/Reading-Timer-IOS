import UIKit
import Social

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Extract URL from shared content
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachment = item.attachments?.first as? NSItemProvider {
                if attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                        if let shareURL = url as? URL {
                            self.openApp(with: shareURL)
                        }
                    }
                }
            }
        }
    }
    
    private func openApp(with url: URL) {
        let urlString = "philonet-open://\(url.absoluteString)"
        if let appURL = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL) { _ in
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            } else {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        }
    }
}
