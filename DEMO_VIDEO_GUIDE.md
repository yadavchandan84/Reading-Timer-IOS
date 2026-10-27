# Demo Video Guide

## Overview
This guide explains how to create a compelling demo video showcasing all Philonet Reading Timer features.

## Video Structure (5-7 minutes)

### Segment 1: Introduction (30 seconds)
**What to show:**
- App icon on home screen
- Quick app launch
- Brief home screen overview

**Narration:**
"Philonet Reading Timer is your personal reading companion. It helps you track how long you spend reading articles by syncing them from Safari. Today, I'll show you how it works, including our smart merge system that prevents time from jumping backward or being counted twice."

### Segment 2: Sharing from Safari (1 minute)

**Steps to Record:**
1. **Open Safari**
   - Show Safari with a real article (or use example.com)
   - Make sure it's readable content

2. **Tap Share Button**
   - Screen recording captures tap
   - Show share menu appearing

3. **Select Philonet Reader**
   - Scroll through share options (enable it under *More* beforehand so it's visible)
   - Tap "Philonet Reader"
   - Show the "Saved to Philonet Reader" confirmation

4. **Return to App**
   - Switch to the app (the share extension doesn't open it automatically)
   - Article appears in list at top
   - Show article details (title, domain, reading time 0s)

**Narration:**
"First, we share an article from Safari. I'm reading this article about [topic] and want to track my time. I tap Share, select Philonet Reader, and the article is saved. When I switch back to the app, it's in the list. Notice it shows up at the top of our reading list with zero reading time since we just added it."

### Segment 3: Reading an Article (2 minutes)

**Steps to Record:**

1. **Tap Article**
   - Article list → Tap top article
   - Show transition animation

2. **Article Opens in Web View**
   - Article renders
   - Show web view with content
   - Scroll to show readable content
   - Keep for 2-3 seconds

3. **Timer Display**
   - Show timer starts at 00:00
   - Let it run for 5-10 seconds
   - Narrate about the timer

4. **Reading Simulation**
   - Show simulated "reading" (scroll, pause, read)
   - Let timer run for 30+ seconds (shows in MM:SS format)
   - Can do real reading or just wait

5. **Pause Button**
   - Tap Pause (orange button)
   - Timer stops
   - Time is saved

6. **Resume Button**
   - Tap Resume (green button)
   - Timer continues from where it stopped

7. **Background Simulation**
   - Press Home button
   - App goes to background
   - Wait 5 seconds
   - Tap app to return
   - Timer should not have increased
   - Tap Resume to continue

**Narration:**
"Now I tap on the article to read it. The timer automatically starts tracking my reading time. I can see it's displayed in the top section. As I read, the timer continuously updates. If I need to pause, I can tap the Pause button. When I'm ready to continue, I tap Resume. 

One key feature is our smart background handling. When I press Home to go to another app, notice the timer doesn't keep counting. This prevents 'ghost time' from being added when we're not actually reading. When I come back to the app, the timer is ready to resume exactly where it left off."

### Segment 4: Article List with Reading Time (1 minute)

**Steps to Record:**

1. **Go Back to List**
   - Tap Back button
   - Return to article list

2. **Show Updated Article**
   - Show the article now has reading time displayed
   - Example: "🕐 2m 34s"
   - Show it's at the top of the list

3. **Add More Articles (Optional)**
   - If time, show adding 2-3 more articles
   - Show them all in list with different times
   - Sorted by newest first

4. **Delete Gesture**
   - Swipe left on an article
   - Show delete confirmation
   - Tap delete
   - Article removed from list

**Narration:**
"When I return to the list, the article now shows my reading time: 2 minutes and 34 seconds. Over time, as you read multiple articles, they all appear in this list with their accumulated reading times. You can swipe to delete articles you no longer want to track. The list always shows your most recent articles first."

### Segment 5: Debug Panel - Merge Rules (1.5 minutes)

**Steps to Record:**

1. **Open Debug Panel**
   - Tap 🐛 icon
   - Show modal appearing

2. **Merge Rules Tab**
   - First tab should be selected
   - Show three rule cards:
     - Rule 1: Prevent Backward Time
     - Rule 2: Prevent Double Counting
     - Rule 3: Accept Memory Time
   - Scroll to show all rules
   - Read descriptions

3. **Switch to History Tab**
   - Tap "History" tab
   - Show merge history entries
   - Each entry shows:
     - Before/After times
     - Which rule was applied
     - When it happened

4. **Switch to Conflicts Tab**
   - Tap "Conflicts" tab
   - May be empty if no conflicts occurred
   - Show how conflicts would appear
   - Show conflict details if available

5. **Close Debug Panel**
   - Tap Done
   - Return to previous view

**Narration:**
"Now here's the really interesting part - our merge rules engine. This is what sets Philonet apart. The debug panel shows exactly how our app handles conflicts between what's in memory and what's saved to disk.

We have three smart rules:

Rule 1 prevents your reading time from going backward. If the app crashes and loses some memory, it will never show less time than you already had.

Rule 2 prevents double counting. If there's an unusual jump in time - like the time suddenly increases by 10 hours - the app detects this as likely double counting and applies a conservative merge instead.

Rule 3 is for normal cases. When times differ slightly, we trust what's in memory since it's continuously updated during your reading session.

The History tab shows every time a merge has occurred, which rule was applied, and how much time was adjusted. The Conflicts tab shows any detected anomalies that the app had to handle."

### Segment 6: Testing Background Behavior (1 minute) [Optional]

**Steps to Record:**

1. **Open Article Again**
   - Open an article from list
   - Show timer running

2. **Force Background**
   - Home button → background
   - Wait noticeably (5-10 seconds)
   - App in background the whole time

3. **Return to App**
   - Tap app icon
   - Return to article
   - Show timer didn't increase
   - Time is paused
   - Same display as before

4. **Resume and Continue**
   - Tap Resume
   - Show timer continues

**Narration:**
"Let me demonstrate our background handling one more time. I'll open an article and let it read for a moment... Now I'll switch away to another app. [Wait visibly] The app is now in the background. Notice that time is NOT being counted. 

[Return to app] 

I'm back! The timer is in the exact same state it was when I left. The time didn't jump forward. When I tap Resume, it continues right from where we stopped. This ensures your reading time is always accurate and never includes time when you weren't actually reading."

### Segment 7: Conclusion (30 seconds)

**Show:**
- Article list one more time
- Debug panel showing successful merges
- Timer running

**Narration:**
"That's Philonet Reading Timer! It's a simple, focused app that does one thing really well: accurately tracks your reading time. Whether you're reading one article or managing a full reading list, Philonet handles all the complexity behind the scenes - merging memory and disk data, preventing errors, and ensuring your reading statistics are always accurate.

With open-source code and a focus on smart data management, Philonet is the reading timer for users who care about accurate statistics and reliable behavior. Thank you for watching!"

## Recording Tips

### Setup
1. **Use Real Device** (looks more professional than simulator)
   - iPhone 14 or later recommended
   - Ensure charged to 100%
   - Turn off notifications

2. **Screen Recording**
   - Use QuickTime on Mac (iOS device → New Screen Recording)
   - Or use native iOS Screen Recording (Control Center)
   - Record at highest resolution available

3. **Lighting & Audio**
   - Well-lit environment
   - External mic for better audio quality
   - Minimal background noise

### Timing
- Total video: 5-7 minutes
- Pause between segments for narration
- Let interactions settle (0.5s) before showing results

### Narration
- Record separately if possible (in post-production)
- Speak clearly and conversationally
- Emphasize key features:
  - Smart background handling
  - Merge conflict prevention
  - Debug transparency

## Post-Production

### Editing Software
- iMovie (macOS/iOS)
- Final Cut Pro
- Adobe Premiere Pro
- DaVinci Resolve (free)

### Editing Steps
1. Organize screen recordings into timeline
2. Add transitions between segments (0.2-0.3s fades)
3. Add narration audio track
4. Adjust audio levels (-6dB for mix)
5. Add background music (optional, keep quiet)
6. Add text overlays for key points
7. Color correction if needed
8. Export at 1080p or 4K

### Text Overlays (Optional)
- "Smart Background Handling"
- "Merge Conflicts Prevented"
- "Reading Time: 2m 34s"
- "Rule Applied: Accept Memory Time"

### Music Suggestions
- Free sources: YouTube Audio Library, Epidemic Sound trial
- Royalty-free: Artlist, AudioJungle
- Keep volume low (-15dB) under narration

## Upload & Distribution

### YouTube
1. Create channel if needed
2. Upload unlisted or public
3. Add title: "Philonet Reading Timer - iOS App Demo"
4. Add description with key features
5. Add tags: iOS, SwiftUI, Reading, Timer, App
6. Add link to GitHub repo in description

### GitHub
1. Create Release
2. Add demo video link
3. Add demo video link to README.md under "Demo" section

### LinkedIn/Twitter
- Share 30-second highlight clip
- Link to full demo video
- Mention key features

## Checklist

- [ ] All app features demonstrated
- [ ] Merge rules explained clearly
- [ ] Background behavior tested
- [ ] Debug panel shown
- [ ] Narration clear and concise
- [ ] Timing appropriate (not too fast)
- [ ] Audio levels balanced
- [ ] Transitions smooth
- [ ] Video quality high (1080p+)
- [ ] Uploaded to YouTube/platform
- [ ] Link added to GitHub README
- [ ] Link added to GitHub Release

## Sample Script

Feel free to adapt this script for your narration:

---

*[Intro]*
"Hi! This is Philonet Reading Timer, an iOS app that tracks your reading time with built-in smart conflict resolution. Let me walk you through all its features."

*[Safari Share]*
"First, I'll share an article from Safari. I tap Share, select Philonet Reader, and when I switch back to the app it's in my reading list."

*[Reading Article]*
"Now I'll open the article to read it. The timer automatically starts, and I can see it counts up in real time. I can pause whenever I want, and if I need a break, I can resume later. Here's the smart part - when I switch to another app..."

*[Background Behavior]*
"...the timer stops running. No ghost time is added. When I come back, it's exactly where I left it. And I can resume reading at any time."

*[List View]*
"Looking at my reading list, I can see all my articles with their total reading times. The list is organized by newest first, and I can delete articles I'm done with."

*[Debug Panel]*
"The coolest feature is our debug panel. This shows exactly how our merge rules work. We have three rules: prevent backward time, prevent double counting, and accept memory time in normal cases. The history tab shows every merge that's happened, and the conflicts tab shows any anomalies we've detected."

*[Conclusion]*
"That's Philonet Reading Timer. It's a perfect example of thoughtful software design that handles complexity invisibly. Thanks for watching!"

---

## Final Checklist

✅ Script prepared
✅ Device ready
✅ Screen recording setup
✅ All features demonstrated
✅ Audio recorded/edited
✅ Video edited
✅ Uploaded to platform
✅ GitHub repo updated with link
