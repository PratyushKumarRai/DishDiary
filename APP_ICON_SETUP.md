# App Icon Setup Guide

## Current Status
The app name has been updated to "DishDiary", but you need to provide an app icon image.

## What You Need to Do

### Option 1: Provide Your Own Icon Image
1. Create or design a square PNG image (recommended size: 1024x1024 pixels)
2. Save it as `app_icon.png` in the `assets/` folder
3. Run the following command to generate all platform icons:

```bash
flutter pub get
dart run flutter_launcher_icons
```

### Option 2: Use an Online Icon Generator
1. Go to a site like https://appicon.co/ or https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
2. Upload your icon or create one
3. Download the generated icons
4. Replace the files in:
   - `android/app/src/main/res/mipmap-*/ic_launcher.png` (Android)
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (iOS)
   - `web/icons/` (Web)

### Option 3: Use a Simple Text-Based Icon (Temporary)
If you want a quick temporary solution, you can:
1. Open Paint or any image editor
2. Create a 1024x1024 image with a blue background (#1976D2)
3. Add a white restaurant/cooking icon or text "DD"
4. Save as `assets/app_icon.png`
5. Run: `dart run flutter_launcher_icons`

## Current Configuration
- App Name: DishDiary (updated ✓)
- Icon theme color: #1976D2 (Blue)
- Home screen logo: Icons.restaurant_menu

## Next Steps
After adding the icon image file, run:
```bash
flutter pub get
dart run flutter_launcher_icons
flutter clean
flutter run
```
