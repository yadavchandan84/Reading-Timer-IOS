# Quick Start Guide

## 5-Minute Setup

### Prerequisites
- Mac with Xcode 14+ (iOS apps can't be built on Windows/Linux)
- XcodeGen: `brew install xcodegen`
- iPhone or iOS simulator (15.0+)

### Step 1: Generate the Xcode project
```bash
cd Reading-Timer-IOS
xcodegen generate
open PhilonetReadingTimer.xcodeproj
```
This creates the app, share extension and test targets. It also generates the Info.plists, URL scheme and App Group entitlements.

### Step 2: Set signing
```
Target PhilonetReadingTimer   → Signing & Capabilities → Team
Target PhilonetShareExtension → Signing & Capabilities → Team
```

### Step 3: Build & Run
```
⌘ + R   run on an iPhone simulator
⌘ + U   run unit tests
```

See [XCODE_SETUP.md](XCODE_SETUP.md) if signing or the App Group fails.

## Key Files Reference

| File | Purpose |
|------|---------|
| `Article.swift` | Data models |
| `TimerService.swift` | Timer management |
| `PersistenceService.swift` | File storage |
| `MergeRulesEngine.swift` | Conflict resolution |
| `ContentView.swift` | Article list |
| `ArticleReaderView.swift` | Reading view |
| `DebugPanelView.swift` | Debug interface |

## Common Tasks

### Adding an Article
```
In-app:   tap + on the home screen, enter a URL
Safari:   Share → "Philonet Reader" → switch back to the app
Terminal: xcrun simctl openurl booted "philonet-open://add?url=https%3A%2F%2Fwww.apple.com"
```

### Testing Background Pause
```
1. Open article (timer starts)
2. Press Home button (app backgrounds)
3. Wait 5+ seconds
4. Tap app icon to return
5. Verify timer didn't increase
```

### Testing Merge Rules
```
1. Open article and read (record time)
2. Background and return (pause/resume)
3. Open Debug Panel (🐛 button)
4. Check "Merge History" tab
5. Verify correct rule applied
```

## Troubleshooting

### "xcodegen: command not found"
→ `brew install xcodegen`

### Signing / App Group error
→ Set a Team on both targets; change bundle IDs and App Group if taken (see XCODE_SETUP.md)

### "Share Extension not appearing"
→ Run the main app scheme, enable "Philonet Reader" under More in the share sheet, restart simulator

### Shared article doesn't show up
→ App Group must match in both targets and `SharedInbox.appGroupID`; switch back to the app to trigger import

### New file "not in scope"
→ Put it in a source folder and re-run `xcodegen generate`

## Next Steps

1. ✅ Project configured
2. ✅ Files added
3. 🏃 Run on simulator
4. 🧪 Test features
5. 📱 Run on device
6. 🎥 Record demo video
7. 📤 Push to GitHub

## Resource Links

- **Xcode Documentation**: https://developer.apple.com/xcode/
- **SwiftUI Docs**: https://developer.apple.com/swiftui/
- **WebKit**: https://developer.apple.com/documentation/webkit
- **File Persistence**: https://developer.apple.com/documentation/foundation/filemanager

## Support Files
- `README.md` - Project overview
- `SETUP.md` - Detailed setup
- `FEATURES.md` - Feature reference
- `ARCHITECTURE.md` - Design details
- `DEMO_VIDEO_GUIDE.md` - Video creation guide
- `XCODE_SETUP.md` - Step-by-step Xcode

## File Locations

### Swift Files
```
project.yml                         (XcodeGen project spec)
PhilonetReadingTimer/
├── PhilonetReadingTimer/           (app target)
│   ├── Models/Article.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── ArticleReaderView.swift
│   │   └── DebugPanelView.swift
│   ├── Services/
│   │   ├── TimerService.swift
│   │   ├── PersistenceService.swift
│   │   └── MergeRulesEngine.swift
│   ├── Utilities/Extensions.swift
│   └── PhilonetReadingTimerApp.swift
├── PhilonetShareExtension/         (share extension target)
│   └── ShareViewController.swift
├── Shared/                         (compiled into both targets)
│   └── SharedInbox.swift
├── PhilonetReadingTimerTests/      (unit test target)
└── Config/                         (generated plists + entitlements)
```

### Data Persistence
```
Documents/
└── articles.json
    └── [Array of Article objects]
```

## Debugging Features

### Debug Panel (🐛)
- **Accessible from**: Home screen (top left), Article reader (top right)
- **Shows**:
  - Merge rule explanations
  - Merge history with timestamps
  - Detected conflicts
  - Time adjustments

### Merge Rules Reference

**Rule 1**: Prevent Backward
- Detects: memory < disk
- Action: Keep disk time
- Reason: Prevent crash rollback

**Rule 2**: Prevent Double Counting
- Detects: Suspicious jump
- Action: Conservative merge (80%)
- Reason: Detect accidental duplication

**Rule 3**: Accept Memory
- Detects: Normal difference
- Action: Use memory time
- Reason: Memory is continuously updated

## Performance Notes

- Timer updates: 1 second intervals
- Persistence: On pause only
- File format: JSON (human-readable)
- Memory limit: 100 conflicts in history
- Target device: iPhone 15+
- Min iOS: 15.0

## Testing Checklist

- [ ] App builds without errors
- [ ] Simulator runs without crashes
- [ ] Safari share works
- [ ] Article appears in list
- [ ] Timer starts/stops
- [ ] Pause/resume works
- [ ] Background pause works
- [ ] Delete article works
- [ ] Debug panel displays correctly
- [ ] Merge rules are logged
- [ ] Device build succeeds
- [ ] Share extension visible in Safari

## Security Notes

- No authentication needed
- No network calls (offline-first)
- URL schemes validated
- Standard sandbox permissions
- Documents folder only
- No sensitive data

## Browser Compatibility

The web view supports:
- HTML5
- JavaScript (enabled)
- Images
- CSS (most modern)
- Videos (streaming)
- Not supported: Flash, Java plugins

## Next: GitHub Setup

1. Initialize git repo
2. Add all files
3. Create initial commit
4. Create GitHub repo
5. Push to GitHub
6. Add demo video link to README
7. Create Release with demo link

Commands:
The generated `.xcodeproj` is git-ignored; `project.yml` is the source of truth.

```bash
git init
git add .
git commit -m "Initial commit: Philonet Reading Timer iOS app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/PhilonetReadingTimer.git
git push -u origin main
```
