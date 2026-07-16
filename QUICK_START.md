# Quick Start Guide

## 5-Minute Setup

### Prerequisites
- Mac with Xcode 14+ installed
- iPhone or iOS simulator (15.0+)
- This code repository

### Step 1: Open Xcode
```
Open Xcode from Applications
```

### Step 2: Create New Project
```
File → New → Project
Platform: iOS
Template: App
Name: PhilonetReadingTimer
Interface: SwiftUI
```

### Step 3: Copy Files
```
Drag and drop all Swift files to Xcode project
Maintain folder structure:
  ├─ Models/
  ├─ Services/
  ├─ Views/
  ├─ Utilities/
  └─ ShareExtension/
```

### Step 4: Add Frameworks
```
Project Settings → Targets → Build Phases
Link Binary With Libraries → +
Add: WebKit
Add: UserNotifications
```

### Step 5: Configure URL Scheme
```
Project Settings → Info → URL Types
Add new:
  Identifier: philonet-open
  Scheme: philonet-open
```

### Step 6: Create Share Extension
```
File → New → Target
Choose: Share Extension
Name: ShareExtension
```

### Step 7: Build & Run
```
⌘ + R (or Product → Run)
Select iPhone 15+ simulator
```

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

### Testing Share Extension
```
1. Open Safari on simulator
2. Navigate to any website
3. Tap Share button
4. Select "Philonet Reading Timer"
5. Check app for new article
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

### "WebKit not found"
→ Add WebKit in Build Phases

### "Share Extension not appearing"
→ Restart simulator, check Info.plist

### "App crashes on background"
→ Check TimerService lifecycle observers

### "Merge rules not working"
→ Verify PersistenceService.shared is singleton

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
PhilonetReadingTimer/
├── Models/
│   └── Article.swift
├── Views/
│   ├── ContentView.swift
│   ├── ArticleReaderView.swift
│   └── DebugPanelView.swift
├── Services/
│   ├── TimerService.swift
│   ├── PersistenceService.swift
│   └── MergeRulesEngine.swift
├── Utilities/
│   └── Extensions.swift
├── ShareExtension/
│   └── ShareViewController.swift
└── PhilonetReadingTimerApp.swift
```

### Data Persistence
```
Documents/
└── articles.json
    └── [Array of Article objects]
```

## Debugging Features

### Debug Panel (🐛)
- **Accessible from**: Home screen, Article reader
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
```bash
git init
git add .
git commit -m "Initial commit: Philonet Reading Timer iOS app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/PhilonetReadingTimer.git
git push -u origin main
```
