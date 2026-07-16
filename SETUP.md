## Project Setup Instructions

This document contains step-by-step instructions to set up the Xcode project from the Swift files provided.

### Quick Start

1. Open Xcode
2. Create a new iOS App project:
   - File → New → Project
   - Select iOS
   - Choose App template
   - Project Name: `PhilonetReadingTimer`
   - Organization Identifier: `com.yourcompany`
   - Interface: SwiftUI
   - Life Cycle: SwiftUI App
   
3. Copy all Swift files to the Xcode project:
   - Drag and drop files maintaining folder structure
   - Check "Copy items if needed"
   - Select "Create groups"

4. Configure targets:
   
   **Main App Target:**
   - Minimum Deployment: iOS 15.0
   - Add WebKit framework
   - Add UserNotifications framework
   
   **Share Extension Target:**
   - File → New → Target
   - Select Share Extension
   - Name: `ShareExtension`
   - Embed in: PhilonetReadingTimer
   - Replace ShareViewController.swift with our code

5. Configure Info.plist:
   
   Add these keys to main app Info.plist:
   ```xml
   <key>NSBonjourServices</key>
   <array>
       <string>_philonet._tcp</string>
   </array>
   <key>NSLocalNetworkUsageDescription</key>
   <string>Philonet uses local network for article sharing</string>
   <key>NSBonjourServiceTypes</key>
   <array>
       <string>_philonet._tcp</string>
   </array>
   ```

6. Configure URL Scheme:
   - Select Project → PhilonetReadingTimer Target
   - Info tab
   - URL Types section
   - Add new URL Type:
     - Identifier: `philonet-open`
     - URL Scheme: `philonet-open`

7. Configure Share Extension Info.plist:
   
   Add to ShareExtension Info.plist:
   ```xml
   <key>NSExtensionAttributes</key>
   <dict>
       <key>NSExtensionActivationRule</key>
       <string>SUBTYPE == "public.url"</string>
   </dict>
   ```

8. Enable App Groups (optional, for shared data):
   - Select Project → PhilonetReadingTimer Target
   - Signing & Capabilities
   - + Capability
   - App Groups
   - Add: `group.com.yourcompany.philonet`
   
   Then in ShareExtension target:
   - Repeat above steps

9. Build and Run:
   - Select iPhone simulator
   - Product → Build (Cmd+B)
   - Product → Run (Cmd+R)

### Frameworks Required

Add these in Build Phases:
- WebKit (for web view)
- UserNotifications (for permissions)

### Testing on Device

1. Connect iPhone
2. Select device from scheme menu
3. Product → Run (Cmd+R)
4. Trust developer certificate if prompted

### Testing Share Extension

1. Open Safari on simulator/device
2. Find any article
3. Tap Share button
4. Scroll down to find "Philonet Reading Timer"
5. Tap to share URL to app

### Troubleshooting

**Share Extension not appearing:**
- Ensure ShareExtension target is embedded
- Check Info.plist NSExtensionActivationRule
- Restart simulator

**URL scheme not working:**
- Verify URL scheme in Info.plist
- Check AppDelegate URLHandler
- Ensure scheme matches

**WebKit errors:**
- Add WebKit framework to both targets
- Ensure WKWebView imports are present

**Permissions denied:**
- Run on simulator/device
- Grant notification permissions when prompted
