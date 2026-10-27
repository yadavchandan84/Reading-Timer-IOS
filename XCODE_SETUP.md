# Xcode Setup Guide

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen).
You don't create targets or edit Info.plist by hand. The `.xcodeproj` is not committed (see `.gitignore`), so regenerate it after cloning or after editing `project.yml`.

> iOS apps can only be built on macOS. On Windows/Linux you can edit the code, but building and running needs a Mac with Xcode.

## Requirements

| Tool | Version |
|------|---------|
| macOS | 12+ |
| Xcode | 14+ |
| XcodeGen | 2.35+ (`brew install xcodegen`) |
| iOS deployment target | 15.0 |

## Step 1: Generate the project

```bash
cd Reading-Timer-IOS
xcodegen generate
open PhilonetReadingTimer.xcodeproj
```

This creates three targets:

| Target | Type | Sources |
|--------|------|---------|
| `PhilonetReadingTimer` | iOS app | `PhilonetReadingTimer/PhilonetReadingTimer/`, `PhilonetReadingTimer/Shared/` |
| `PhilonetShareExtension` | Share Extension (embedded in the app) | `PhilonetReadingTimer/PhilonetShareExtension/`, `PhilonetReadingTimer/Shared/` |
| `PhilonetReadingTimerTests` | Unit tests | `PhilonetReadingTimer/PhilonetReadingTimerTests/` |

It also generates these files in `PhilonetReadingTimer/Config/`:
- `App-Info.plist`: includes the `philonet-open` URL scheme and launch screen
- `ShareExtension-Info.plist`: share-services extension point, accepts web URLs and text
- `App.entitlements` / `ShareExtension.entitlements`: App Group `group.com.philonet.readingtimer`

WebKit is linked automatically. No other frameworks need to be added.

## Step 2: Signing

1. Select the project → target **PhilonetReadingTimer** → **Signing & Capabilities**.
2. Tick *Automatically manage signing* and choose your **Team**.
3. Repeat for **PhilonetShareExtension**.

To avoid redoing this after every regenerate, put your team ID in `project.yml` (`DEVELOPMENT_TEAM`).

### If the bundle ID or App Group is already taken
Bundle IDs and App Group IDs must be unique per Apple account. To change them:
1. In `project.yml`, change `com.philonet.readingtimer` (all three targets) and `group.com.philonet.readingtimer` (both entitlements).
2. In `PhilonetReadingTimer/Shared/SharedInbox.swift`, set `appGroupID` to the same group.
3. Run `xcodegen generate` again.

## Step 3: Build and run

- Pick the **PhilonetReadingTimer** scheme and an iPhone simulator.
- ⌘B to build, ⌘R to run, ⌘U to run unit tests.

## Step 4: Try it out

### Add an article
- **In-app**: tap **+** on the home screen and enter a URL. This is the quickest way on the simulator.
- **From Safari**: open a page → Share → **Philonet Reader** (you may need to scroll the app row and tap *More*). Then switch back to the app. The article is imported when the app becomes active.
- **URL scheme**: run this in Terminal while the simulator is running:
  ```bash
  xcrun simctl openurl booted "philonet-open://add?url=https%3A%2F%2Fwww.apple.com%2Fnewsroom"
  ```

### Timer
1. Open an article. The timer starts.
2. Tap Pause or Resume. Each pause saves the time through the merge rules.
3. Press Home (⇧⌘H in the simulator). The timer pauses and saves.
4. Return to the app. The timer stays paused until you tap Resume.

### Debug panel
Tap 🐛 (top left on the home screen, top right in the reader). The **History** tab lists every merge, and **Conflicts** lists Rule 1/Rule 2 hits.

## How sharing works

App extensions can't open their host app (`UIApplication.shared` is unavailable). Instead:

1. `ShareViewController` extracts the URL and calls `SharedInbox.enqueue(_:)`. That writes it to `UserDefaults(suiteName: appGroupID)`.
2. When the app becomes active, `PersistenceService.importPendingSharedArticles()` drains the queue and adds the articles.

## Troubleshooting

**`xcodegen: command not found`**
Install it with `brew install xcodegen`, or download a release from GitHub.

**Signing error: "Personal development teams do not support the App Groups capability"**
Some free Apple accounts can't use App Groups. You can still run the app: remove the `entitlements` blocks from `project.yml`, regenerate, and add articles with **+** or the URL scheme. Safari sharing then won't reach the app.

**Share extension not listed in Safari**
- Make sure you ran the **PhilonetReadingTimer** scheme (it embeds the extension), not the extension alone.
- In the share sheet, tap *More* and enable **Philonet Reader**.
- Restart the simulator if the extension list is stale.

**Shared article doesn't appear**
- Both targets must have the same App Group, and it must match `SharedInbox.appGroupID`.
- The import runs when the app becomes active. Switch away and back if the app was already open.

**"Cannot find X in scope" after adding files**
Add new files under one of the source folders listed above, then re-run `xcodegen generate`. Files added only through Xcode's UI are lost the next time you regenerate.

**Articles not persisting**
Data is stored at `Documents/articles.json` in the app sandbox. Deleting the app clears it. Check the Xcode console for `Error saving articles`.

## Device testing

1. Connect an iPhone and select it as the run destination.
2. Make sure signing is set for both targets (Step 2).
3. Press ⌘R. On first launch, trust the developer certificate under Settings → General → VPN & Device Management.
