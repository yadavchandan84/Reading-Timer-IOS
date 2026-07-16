# Implementation Guide for Xcode

## Step 1: Create Xcode Project

### New Project Setup
```
File → New → Project
├─ Platform: iOS
├─ Application type: App
├─ Project Name: PhilonetReadingTimer
├─ Team: Your Development Team
├─ Organization Identifier: com.yourcompany
├─ Interface: SwiftUI
├─ Life Cycle: SwiftUI App
└─ Where: Select your workspace folder
```

## Step 2: Add Files to Project

### Add Swift Files to Main Target

1. **Models Group**
   - Right-click PhilonetReadingTimer → New Group → "Models"
   - Drag `Article.swift` into Models
   - Uncheck "Copy items if needed" (already in folder)

2. **Services Group**
   - Right-click PhilonetReadingTimer → New Group → "Services"
   - Drag these files:
     - `MergeRulesEngine.swift`
     - `PersistenceService.swift`
     - `TimerService.swift`

3. **Views Group**
   - Right-click PhilonetReadingTimer → New Group → "Views"
   - Drag these files:
     - `ContentView.swift`
     - `ArticleReaderView.swift`
     - `DebugPanelView.swift`

4. **Utilities Group**
   - Right-click PhilonetReadingTimer → New Group → "Utilities"
   - Drag `Extensions.swift`

5. **Root Level**
   - Drag `PhilonetReadingTimerApp.swift` (replace existing)

## Step 3: Configure Frameworks

### Add WebKit Framework
1. Select Project → PhilonetReadingTimer Target
2. Build Phases → Link Binary With Libraries
3. Click `+` and search for "WebKit"
4. Select WebKit.framework → Add

### Add UserNotifications Framework
1. Repeat above process
2. Search for "UserNotifications"
3. Select UserNotifications.framework → Add

## Step 4: Configure Deployment Target

1. Select Project → PhilonetReadingTimer Target
2. General tab
3. Set Minimum Deployment to iOS 15.0 or higher

## Step 5: Create Share Extension

### New Target
1. File → New → Target
2. Choose "Share Extension"
3. Name: `ShareExtension`
4. Embed in: `PhilonetReadingTimer`
5. Create

### Add Share Extension Code
1. Delete auto-generated ShareViewController.swift
2. Drag our `ShareViewController.swift` from ShareExtension folder
3. Ensure it's added to ShareExtension target

## Step 6: Configure URL Scheme

### In Main App
1. Select Project → PhilonetReadingTimer Target
2. Info tab (or open Info.plist)
3. Scroll to "URL Types" (may need to create)
4. Click `+` to add URL Type:
   - Identifier: `philonet-open`
   - URL Scheme: `philonet-open`

## Step 7: Configure App Delegate

### Enable App Delegate Integration
1. In `PhilonetReadingTimerApp.swift`, the `@UIApplicationDelegateAdaptor` is already configured
2. The AppDelegate handles URL scheme routing

## Step 8: Share Extension Configuration

### Configure Info.plist
1. Select ShareExtension target
2. Info.plist
3. Add these keys:

```xml
<key>NSExtensionAttributes</key>
<dict>
    <key>NSExtensionActivationRule</key>
    <string>SUBTYPE == "public.url"</string>
</dict>
```

## Step 9: Build Settings

### Verify Build Settings
1. Select Project
2. Build Settings
3. Search for "Swift Language Version"
4. Ensure it's Swift 5.5 or later

## Step 10: Build and Run

### Build
```
⌘ + B (or Product → Build)
```

### Run on Simulator
```
⌘ + R (or Product → Run)
```

Select iPhone 15 or later simulator.

## Step 11: Test Share Extension

### On Simulator
1. Open Simulator
2. Open Safari
3. Navigate to any website
4. Tap Share button (↗️)
5. Scroll down in share sheet
6. Look for "Philonet Reading Timer"
7. Tap it to share

### On Device
1. Trust developer certificate (if prompted)
2. Repeat steps above

## Step 12: Create Test Target

### Add Tests
1. File → New → Target
2. Choose "Unit Testing Bundle"
3. Name: `PhilonetReadingTimerTests`
4. Add `PhilonetReadingTimerTests.swift`

### Run Tests
```
⌘ + U (or Product → Test)
```

## Troubleshooting

### Share Extension Not Appearing

**Problem**: Share extension doesn't show in Share menu
**Solutions**:
1. Verify ShareExtension is embedded (Build Phases → Embed Content)
2. Check Info.plist NSExtensionActivationRule
3. Restart simulator (or kill and reopen Safari)
4. Rebuild project (⌘ + B)

### Compilation Errors

**Problem**: "WebKit not found"
**Solution**: Ensure WebKit is added to Link Binary With Libraries

**Problem**: "Cannot find 'PersistenceService' in scope"
**Solution**: Verify all Swift files are added to target (Build Phases → Compile Sources)

### Runtime Errors

**Problem**: "URL scheme not working"
**Solutions**:
1. Verify URL scheme in Info.plist
2. Check AppDelegate handles URL: `application(_:open:options:) -> Bool`
3. Verify scheme name matches

**Problem**: "Articles not persisting"
**Solutions**:
1. Check Documents folder permissions
2. Verify PersistenceService initialization
3. Check file permissions in app sandbox

### Simulator Issues

**Problem**: "App crashes on background"
**Solution**: Check app lifecycle handling in TimerService

**Problem**: "No simulator devices available"
**Solution**: 
1. Xcode → Preferences → Platforms
2. Ensure iOS is installed
3. Add simulator: Xcode → Preferences → Devices

## Next Steps

1. ✅ Project setup complete
2. 📱 Run on simulator to test
3. 🔗 Test URL sharing
4. 📊 Review debug panel
5. 🎥 Record demo video

## Advanced Configuration

### For Device Testing

1. Select Device from Scheme
2. Plug in iPhone
3. Trust developer certificate when prompted
4. Run (⌘ + R)

### For Release Build

1. Edit Scheme → Run → Release
2. This uses optimized build
3. Closer to App Store behavior

### Enable Signing

1. Select Project → PhilonetReadingTimer
2. Signing & Capabilities
3. Select Team
4. Let Xcode manage signing
