## Project Setup

The project is defined in `project.yml` and generated with XcodeGen. You don't need to create a project, add targets or edit Info.plist by hand.

### Steps (on a Mac)

```bash
brew install xcodegen
cd Reading-Timer-IOS
xcodegen generate
open PhilonetReadingTimer.xcodeproj
```

1. Set your Team under **Signing & Capabilities** for both `PhilonetReadingTimer` and `PhilonetShareExtension`.
2. Choose an iPhone simulator and press ⌘R. Press ⌘U to run tests.

### What `project.yml` configures

| Setting | Value |
|---------|-------|
| Deployment target | iOS 15.0 |
| App bundle ID | `com.philonet.readingtimer` |
| Extension bundle ID | `com.philonet.readingtimer.ShareExtension` |
| App Group (both targets) | `group.com.philonet.readingtimer` |
| URL scheme | `philonet-open://add?url=<percent-encoded URL>` |
| Share activation | web URLs (max 1) and text |
| Frameworks | WebKit (SwiftUI/UIKit/Foundation are implicit) |

If you change the App Group, also update `SharedInbox.appGroupID` in `PhilonetReadingTimer/Shared/SharedInbox.swift`, then regenerate.

### Testing the Share Extension

1. Run the app once so the extension is installed.
2. Open Safari → any article → Share → **Philonet Reader**. You may need to tap *More* to enable it.
3. Switch back to the app. The article is imported automatically.

### Troubleshooting

See the Troubleshooting section in [XCODE_SETUP.md](XCODE_SETUP.md). It covers signing and App Group errors, the extension not appearing, and shared links not arriving.
