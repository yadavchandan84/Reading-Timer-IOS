import UIKit
import UniformTypeIdentifiers

/// Share Extension entry point. Receives a URL from Safari (or any app),
/// queues it in the shared App Group inbox, and dismisses itself.
/// The main app imports queued URLs the next time it becomes active.
class ShareViewController: UIViewController {
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractSharedURL { [weak self] url in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let url = url {
                    SharedInbox.enqueue(url)
                    self.finish(message: "Saved to Philonet Reader")
                } else {
                    self.finish(message: "No link found to save")
                }
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        statusLabel.text = "Saving…"
        statusLabel.font = .preferredFont(forTextStyle: .headline)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16)
        ])
    }

    /// Looks for a URL attachment first, then falls back to plain text containing a link.
    private func extractSharedURL(completion: @escaping (URL?) -> Void) {
        let providers = (extensionContext?.inputItems as? [NSExtensionItem] ?? [])
            .flatMap { $0.attachments ?? [] }

        let urlType = UTType.url.identifier
        let textType = UTType.plainText.identifier

        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(urlType) }) {
            provider.loadItem(forTypeIdentifier: urlType, options: nil) { item, _ in
                if let url = item as? URL {
                    completion(url)
                } else if let string = item as? String {
                    completion(URL(string: string))
                } else {
                    completion(nil)
                }
            }
        } else if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(textType) }) {
            provider.loadItem(forTypeIdentifier: textType, options: nil) { item, _ in
                completion(Self.firstLink(in: item as? String))
            }
        } else {
            completion(nil)
        }
    }

    private static func firstLink(in text: String?) -> URL? {
        guard let text = text,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        return detector.firstMatch(in: text, options: [], range: range)?.url
    }

    private func finish(message: String) {
        statusLabel.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
