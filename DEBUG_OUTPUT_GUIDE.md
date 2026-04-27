# Debug Output Guide

When you use the YouTube recipe extraction feature, you'll now see comprehensive debug output in your terminal/console.

## AI Services Used:
- **Mistral AI** - For all AI conversations, recipe generation, and YouTube extraction
- **Tavily** - For web-grounded recipe searches (optional enhancement)

## What You'll See:

### 1. **YouTube Recipe Extraction Start**
```
🎬 === YouTube Recipe Extraction ===
  URL: https://youtube.com/watch?v=...
```

### 2. **Metadata Extraction**
```
📄 Fetching watch page metadata for video: ...
📊 Watch page HTML size: 12345 bytes
🔍 Found ytInitialPlayerResponse
📝 Title from videoDetails: Chocolate Cake Recipe
📝 Description from videoDetails: 1234 chars
👤 Channel: Cooking Channel
👁️ Views: 1000000
⏱️ Duration: 10m 30s
🏷️ Keywords: chocolate, cake, dessert, ...
🖼️ Thumbnail: https://...
📝 Video has 3 caption track(s) available
  - English (en) [AUTO]
  - Spanish (es) [MANUAL]
```

### 3. **Extracted Metadata Summary**
```
📊 Extracted Metadata:
  📝 Title: Chocolate Cake Recipe
  👤 Author: Cooking Channel
  📄 Description: 1234 chars
  ⏱️ Duration: 10m 30s
  🏷️ Keywords: chocolate, cake, dessert...
  📅 Published: Apr 10, 2024
  👁️ Views: 1,000,000
  📝 Has Captions: true
```

### 4. **Transcript Fetching**
If captions are available and user didn't provide transcript:
```
📡 Auto-fetching transcript from video...
✅ Auto-fetched transcript: 5678 characters
  📝 Transcript preview: welcome to this video today we're making...
```

If user provided transcript:
```
📝 Using user-provided transcript: 4567 characters
```

### 5. **AI Processing**
```
🚀 Mistral request → model: mistral-large-latest
✅ Mistral responded in 2345ms  (3456 bytes)
```

### 6. **Mistral Response Debug**
```
🔍 DEBUG - Mistral raw response: 2345 chars
✅ Recipe extracted: Chocolate Cake Recipe
```

## How to Disable Debug Output:

If you want to disable debug output in production, edit `lib/services/mistral_service.dart`:

```dart
// Change this line (around line 24):
static const bool debugEnabled = true;

// To:
static const bool debugEnabled = false;
```

## Where to See Debug Output:

- **VS Code**: Terminal tab (when running `flutter run`)
- **Android Studio**: Run console at the bottom
- **Command Line**: The terminal where you run `flutter run`

All debug messages are prefixed with emojis and clear labels for easy identification!
