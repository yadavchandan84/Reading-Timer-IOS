# Philonet Reading Timer: Start Here

An iOS read-it-later app. You share articles from Safari and read them in-app. A timer tracks reading time, and a merge-rules engine keeps the saved time consistent between memory and disk.

## Get it running (Mac required)

```bash
brew install xcodegen
cd Reading-Timer-IOS
xcodegen generate
open PhilonetReadingTimer.xcodeproj
```

1. Set your Team for the `PhilonetReadingTimer` and `PhilonetShareExtension` targets (Signing & Capabilities).
2. Press ⌘R on an iPhone simulator. Press ⌘U to run tests.
3. Tap **+** to add a URL, or share a page from Safari to **Philonet Reader**.

Full details and troubleshooting are in [XCODE_SETUP.md](XCODE_SETUP.md).

> The project can't be built on Windows/Linux. The `.xcodeproj` is generated from `project.yml` and is not committed.

## Features

- **Article sharing**: a Safari Share Extension hands links to the app through an App Group. You can also add links with **+** or the `philonet-open://add?url=…` scheme.
- **Reading timer**: starts when you open an article and pauses (and saves) when the app backgrounds or you leave the reader. Resume continues where you left off.
- **Merge rules engine**:
  1. Prevent backward time: if memory < disk, keep disk.
  2. Prevent double counting: if the jump is implausible, add only 80% of the difference.
  3. Accept memory time: the normal case.
- **Debug panel** (🐛): rule explanations, merge history, and detected conflicts.
- **Persistence**: JSON file at `Documents/articles.json`.

## Project structure

```
project.yml                              XcodeGen spec (targets, plists, entitlements)
PhilonetReadingTimer/
├── PhilonetReadingTimer/                App target
│   ├── Models/Article.swift
│   ├── Services/
│   │   ├── TimerService.swift
│   │   ├── PersistenceService.swift
│   │   └── MergeRulesEngine.swift
│   ├── Views/
│   │   ├── ContentView.swift            List + "Add Article" sheet
│   │   ├── ArticleReaderView.swift      Web view + timer
│   │   └── DebugPanelView.swift
│   ├── Utilities/Extensions.swift
│   └── PhilonetReadingTimerApp.swift    Entry point, URL scheme, share import
├── PhilonetShareExtension/
│   └── ShareViewController.swift        Share Extension target
├── Shared/
│   └── SharedInbox.swift                App Group hand-off (both targets)
├── PhilonetReadingTimerTests/
│   └── PhilonetReadingTimerTests.swift  10 unit tests
└── Config/                              Generated Info.plists + entitlements
```

## Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Overview and quick start |
| [XCODE_SETUP.md](XCODE_SETUP.md) | Setup, signing, testing, troubleshooting |
| [QUICK_START.md](QUICK_START.md) | Short reference |
| [SETUP.md](SETUP.md) | What `project.yml` configures |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Design and data flow |
| [FEATURES.md](FEATURES.md) | Feature details |
| [DEMO_VIDEO_GUIDE.md](DEMO_VIDEO_GUIDE.md) | Recording a demo |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | Status and checklist |
| [INDEX.md](INDEX.md) | Index of files |

## Status

The code has been fixed so it should compile for iOS 15+. It has not yet been built or tested on a Mac, so build it, run the tests (⌘U), and go through the manual checklist in [XCODE_SETUP.md](XCODE_SETUP.md) before you submit.
