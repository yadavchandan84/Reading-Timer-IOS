# Feature Documentation

## Complete Feature List

### 1. Article Sharing (Safari Integration)

#### How It Works
- Uses iOS Share Extension
- Integrates with Safari through URL scheme
- Saves article metadata (URL, title)

#### User Flow
```
Safari → Share (↗️) → Philonet Reading Timer → Article Saved
```

#### Technical Details
- **Share Extension**: `ShareViewController.swift`
- **URL Scheme**: `philonet-open://`
- **Data Flow**: 
  1. User taps Share in Safari
  2. Share sheet appears
  3. User selects "Philonet Reading Timer"
  4. Extension extracts URL
  5. Opens app via URL scheme
  6. AppDelegate receives URL
  7. Article added to list

### 2. Article Display & Web View

#### Features
- Renders full HTML content
- Scrollable reading area
- Maintains scroll position (optional enhancement)
- Handles various content types

#### Implementation
- Uses `WKWebView` from WebKit framework
- Embedded in `ArticleReaderView`
- Safe area handling for notch/dynamic island

#### Code Location
`ArticleReaderView.swift` → `WebViewContainer`

### 3. Reading Timer

#### Features
- Starts automatically when article opens
- Displays in MM:SS or HH:MM:SS format
- Updates every 1 second
- Shows current elapsed time

#### Smart Behavior
- **Pause**: User taps Pause button (orange)
- **Resume**: User taps Resume button (green)
- **Auto-pause**: When app backgrounds
- **Auto-resume**: Ready when user returns (manual tap needed)

#### UI Components
```
┌─────────────────────────┐
│      Reading Time       │ ← Label
│      MM:SS              │ ← Large monospaced number
├──────────┬──────────────┤
│  Pause   │    Resume    │ ← Buttons
└──────────┴──────────────┘
```

#### Data Tracking
- **Memory Time**: Updated every second
- **Disk Time**: Updated when paused
- **Session Start**: Recorded on open
- **Session End**: Recorded on pause/background

### 4. Article List

#### Features
- Shows all saved articles
- Sorted by date (newest first)
- Displays title, domain, reading time
- Swipe to delete
- Empty state with guidance

#### Information Displayed
```
[Title]
example.com        🕐 1h 23m 45s
```

#### Interactions
- **Tap**: Open article for reading
- **Swipe Left**: Delete with confirmation
- **Pull Refresh**: Manual refresh (optional)

### 5. Timer Pause/Resume on Background

#### Background Detection
```
App Active (Foreground)
    ↓
Timer Running (1s intervals)
    ↓
UIApplication.didEnterBackgroundNotification
    ↓
pauseTimer() called
    ↓
Time saved to disk
    ↓
App in Background
    ↓
Timer NOT running
    ↓
User returns
    ↓
Resume button available
    ↓
resumeTimer() on tap
```

#### No Ghost Time
- Timer completely stops in background
- No hidden counting occurs
- Prevents battery drain

#### Implementation
`TimerService.swift`:
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(appDidEnterBackground),
    name: UIApplication.didEnterBackgroundNotification,
    object: nil
)
```

### 6. Memory & Disk Persistence

#### Architecture
```
Memory (RAM)
├─ Current reading session
├─ Continuously updated
└─ Lost on app restart

Disk (Documents/articles.json)
├─ Persistent storage
├─ Updated when app pauses
└─ Loaded on app launch
```

#### Sync Process
1. **Session Start**
   - Load from disk
   - Initialize memory

2. **Session Active**
   - Memory updates: every 1 second
   - Disk: no updates (performance)

3. **Session Pause**
   - Memory → Disk sync
   - JSON serialization
   - File write to Documents folder

4. **App Background**
   - Automatic pause
   - Memory → Disk sync

5. **App Restart**
   - Load from disk
   - Restore article list
   - Ready to continue reading

### 7. Merge Rules Engine

#### Rule 1: Prevent Backward Time
```
Scenario: App crashed, memory lost
Memory:  300s (old state)
Disk:    600s (correct state)
Result:  Keep 600s (newer)
Logic:   if memory < disk → use disk
```

#### Rule 2: Prevent Double Counting
```
Scenario: Unusual time jump
Memory:   50,000s (14 hours!)
Disk:     5,000s (normal)
Difference: 45,000s (impossible in one session)
Result:   Use disk + 80% of difference
Logic:    Detects anomalies, applies conservative merge
```

#### Rule 3: Accept Memory Time
```
Scenario: Normal reading session
Memory:   1,200s
Disk:     1,000s
Difference: 200s (reasonable 3-minute gap)
Result:   Accept memory (1,200s)
Logic:    Memory is continuously updated during session
```

#### Crash Detection
- Threshold: >30 seconds difference
- Logged as conflict
- Recorded in debug panel

### 8. Debug Panel

#### Tab 1: Merge Rules Explanation

Shows three rule cards:
- **Rule 1**: Backward prevention
- **Rule 2**: Double counting prevention
- **Rule 3**: Normal case acceptance

Each card includes:
- Icon
- Title
- Description
- Real-world example

#### Tab 2: Merge History

Shows all merge operations:
- **Before Time**: Previous disk value
- **After Time**: New disk value
- **Delta**: Time added
- **Rule Applied**: Which rule was used
- **Timestamp**: When merge occurred

Example:
```
Rule 3: Accept memory time
Before: 1000s
After: 1200s
Delta: +200s
Timestamp: Jan 15, 2024 2:45 PM
```

#### Tab 3: Conflict Detection

Shows all detected conflicts:
- **Reason**: Why conflict was detected
- **Memory**: Time in memory
- **Disk**: Time on disk
- **Diff**: Difference
- **Timestamp**: When detected

Example:
```
Likely double counting detected
Memory: 50,000s
Disk: 5,000s
Diff: 45,000s
Timestamp: Jan 15, 2024 2:30 PM
```

#### Debug Access Points
- Home screen: 🐛 button (top right)
- Reader view: 🐛 button (top right)
- Fully modal presentation

### 9. Data Persistence Format

#### JSON Structure
```json
{
  "id": "UUID-string",
  "url": "https://example.com/article",
  "title": "Article Title",
  "addedDate": "2024-01-15T14:30:00Z",
  "totalReadingTime": 1200,
  "lastReadDate": "2024-01-15T15:45:00Z"
}
```

#### File Location
- **iOS**: `Documents/articles.json`
- **Accessible**: Via Files app (optional)
- **Backup**: Included in iCloud backup (can be enabled)

### 10. User Interface

#### Color Scheme
- **Primary**: Blue (#007AFF)
- **Accent**: Orange (#FF9500) for pause
- **Success**: Green (#34C759) for resume
- **Background**: System gray backgrounds

#### Typography
- **Headlines**: System Bold
- **Body**: System Regular
- **Monospace**: For timer display

#### Layout
- SafeArea respected
- Notch/Dynamic Island support
- Bottom margin for home indicator
- Standard iOS spacing (8pt grid)

## Advanced Features (Optional Enhancements)

### Article Tagging
- Allow users to categorize articles
- Filter by tag on home screen
- Multiple tags per article

### Reading Statistics
- Total reading time per day/week/month
- Average article length
- Most read categories

### Cross-Device Sync
- iCloud sync with CloudKit
- Automatic sync across devices
- Conflict resolution for sync conflicts

### Article Search
- Full-text search by title
- Domain filtering
- Date range filtering

### Reading Goals
- Daily reading target
- Weekly summaries
- Achievement notifications

### Export Functionality
- Export reading history as CSV
- Share statistics
- Backup to email

## Testing Checklist

### Basic Functionality
- [ ] Share from Safari works
- [ ] Article appears in list
- [ ] Timer starts on open
- [ ] Timer pauses on pause button
- [ ] Timer resumes on resume button
- [ ] Timer stops on background
- [ ] Time persists after close
- [ ] Delete article works

### Merge Rules
- [ ] Backward time prevented
- [ ] Double counting detected
- [ ] Normal merge accepted
- [ ] Conflict logged in debug panel

### Debug Panel
- [ ] Rules explanation displays correctly
- [ ] Merge history shows entries
- [ ] Conflicts logged accurately
- [ ] Clear history works

### Edge Cases
- [ ] App force quit during reading
- [ ] Low battery mode
- [ ] Device rotation
- [ ] Multiple articles open/close
- [ ] Very large reading times
