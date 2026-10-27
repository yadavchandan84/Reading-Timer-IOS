# Architecture & Design Decisions

## Overview
This document explains the architectural choices and design patterns used in Philonet Reading Timer.

## Data Flow

```
Safari Share                         In-app "+" / philonet-open://add?url=…
    ↓                                        ↓
Share Extension (ShareViewController)   App .onOpenURL / AddArticleView
    ↓                                        │
SharedInbox.enqueue (App Group defaults)     │
    ↓                                        │
App becomes active →                         │
PersistenceService.importPendingSharedArticles()
    ↓                                        ↓
Persistence Service (addArticle) ←───────────┘
    ↓
ContentView (Article List)
    ↓
ArticleReaderView (Web View + Timer)
    ↓
TimerService (Tracks Time)
    ↓
MergeRulesEngine (Resolves Conflicts)
    ↓
PersistenceService (Save to Disk)
```

## Component Details

### Models (Article.swift)
- **Article**: Represents a saved article with URL, title, reading times (memory & disk)
- **ReadingSession**: Tracks a single reading session
- **ReadingTimeConflict**: Represents a detected conflict between memory and disk
- **MergeResult**: Tracks result of applying merge rules

**Design Decision**: Separating memory and disk reading times allows us to detect and resolve conflicts.

### Services

#### TimerService
- Manages timer lifecycle: start, pause, resume, stop
- Observes app lifecycle: pauses (and saves) on background/terminate; resume is manual
- Updates every 1 second; the timer runs in `.common` run-loop mode so it keeps ticking while scrolling
- Accumulates time across pause/resume segments, so resuming continues from the paused value
- Every pause syncs to disk via `PersistenceService.syncReadingTimeWithMergeRules`

**Design Decision**: Using app lifecycle observers ensures we never count "ghost time" when app is backgrounded.

#### PersistenceService
- Singleton (`PersistenceService.shared`) for the app; `init(fileURL:)` lets tests use a temp file
- Stores articles as JSON in Documents folder; loads synchronously on init
- Owns the single `MergeRulesEngine` instance that the Debug Panel observes
- Ignores duplicate URLs; imports links queued by the Share Extension
- All access happens on the main thread (called from SwiftUI and main-queue observers)

#### SharedInbox (Shared/)
- Compiled into both the app and the Share Extension
- Queue of URL strings in `UserDefaults(suiteName: "group.com.philonet.readingtimer")`
- Needed because extensions cannot call `UIApplication.shared.open` to launch the host app

**Design Decision**: An App Group queue is the Apple-supported way to pass data from an extension to its app.

**Design Decision**: JSON persistence is simple, portable, and human-readable for debugging.

#### MergeRulesEngine
- Implements three conflict resolution rules
- Tracks all conflicts and merge history for debugging
- Detects likely crashes based on time differences

**Design Decision**: Separate engine allows testing rules independently and provides audit trail.

### Views

#### ContentView
- Main app screen with article list
- Empty state guidance
- "+" button to add an article by URL
- Debug button access
- Delete functionality with swipe

#### ArticleReaderView
- Web view for reading articles (with loading indicator)
- Timer display and controls
- Manual pause/resume buttons
- Debug access during reading

#### DebugPanelView
- Three-tab interface:
  - Rules Explanation
  - Merge History with before/after values
  - Conflict Detection Log
- Educational component showing merge logic in action

**Design Decision**: Debug panel makes the abstract merge logic concrete and verifiable.

## Key Design Patterns

### MVVM Architecture
- Models: Article, ReadingSession, Conflict
- Views: SwiftUI components
- ViewModels: TimerService, PersistenceService, MergeRulesEngine

### Singleton Pattern
- PersistenceService: Ensures single source of truth for articles
- App-wide access via `PersistenceService.shared`

### Observer Pattern
- App Lifecycle: Timer responds to background/foreground
- NotificationCenter: Loose coupling between components

### Merge Strategy Pattern
- Three different merge rules as separate methods
- Each rule is independent and testable
- Can be extended with new rules

## Data Consistency Strategy

### Memory vs Disk
- **Memory**: Continuously updated, true during active session
- **Disk**: Persisted state, source of truth after app exit
- **Conflict**: When they disagree (e.g., after crash)

### Resolution Rules

1. **Prevent Backward**: Never show less time than before
   - Handles: App crashes that lose memory updates

2. **Prevent Double Counting**: Detect suspicious jumps
   - Handles: Accidental duplicate counting
   - Uses: Conservative approach (80% of difference)

3. **Accept Memory**: Normal case
   - Handles: Regular reading sessions

## File Storage

```
Documents/
└── articles.json
    [
      {
        "id": "UUID",
        "url": "https://...",
        "title": "Article Title",
        "addedDate": "2024-01-15T...",
        "totalReadingTime": 1200,
        "lastReadDate": "2024-01-15T..."
      }
    ]
```

## Security Considerations

- **No Authentication**: Simple app, no user accounts
- **URL Handling**: `philonet-open://add?url=` only accepts `http`/`https` article URLs (no `javascript:`, `file:` etc.)
- **Sandboxing**: Uses standard Documents directory
- **Data**: No sensitive data, URLs are user-shared

## Performance Optimizations

- **Timer Resolution**: 1 second intervals (not per-millisecond)
- **Batch Persistence**: Save only when paused, not continuously
- **Lazy Loading**: Articles loaded on app launch
- **Memory Management**: Merge history limited to 100 items

## Testing Strategy

Three levels of testing:

1. **Unit Tests**: MergeRulesEngine logic
2. **Integration Tests**: PersistenceService flow
3. **UI Tests**: Manual testing of views

See `PhilonetReadingTimerTests.swift` for test examples.

## Future Extensibility

### Adding New Merge Rules
1. Implement new rule as method in MergeRulesEngine
2. Call from `resolveMerge()` based on conditions
3. Track in MergeResult with descriptive string
4. Add test case to verify rule

### Adding Analytics
1. Extend MergeResult with additional metadata
2. Send to backend service
3. Add charts to DebugPanel

### Multi-Device Sync
1. Add iCloud sync using Core Data + CloudKit
2. Implement sync conflict detection
3. Extend merge rules for remote conflicts

### Customizable Rules
1. Move rules to configuration
2. Add settings screen
3. Allow user-defined thresholds

## Debugging Tips

1. **Check Merge History**: See what rules were applied
2. **Review Conflicts**: Understand why app detected issues
3. **Check Logs**: Console output shows all merge operations
4. **Test Manually**: 
   - Background app while reading (should pause)
   - Force quit and restart (should handle gracefully)
   - Add article, read, check persistence
