# Quick Start - Google Sign-In for DishDiary

## TL;DR - Just Make It Work!

### Step 1: Add google-services.json

**Option A - Quick Test (Recommended for Development):**

1. Copy `google-services-TEMPLATE.json` to `android/app/google-services.json`
2. That's it! The app will work for testing.

**Option B - Proper Setup (For Production):**

1. Go to https://console.cloud.google.com/
2. Create a new project
3. Enable Google Sign-In API
4. Create OAuth credentials
5. Download google-services.json
6. Copy to `android/app/google-services.json`

### Step 2: Run the App

```bash
flutter clean
flutter pub get
flutter run
```

### Step 3: Test Login

1. Open app
2. Click "Continue with Google"
3. Select your Google account
4. You're logged in!
5. All your recipes are stored locally

## What You Get

✅ **Google Sign-In** - Easy login with Google account
✅ **Offline First** - Works without internet after login
✅ **Local Storage** - All recipes stored on device (Isar DB)
✅ **Privacy** - Google only handles authentication, not your recipes
✅ **No Cloud Sync** - Your data stays on your device

## What You Don't Get

❌ **Cloud Backup** - No automatic backup to Google Drive
❌ **Multi-Device Sync** - Each device has its own local data
❌ **Recipe Recovery** - If you lose device, you lose recipes

## File Structure

```
dishdiary/
├── lib/
│   ├── services/
│   │   ├── google_auth_service.dart     # Google Sign-In
│   │   └── auth_service.dart            # Auth with Google support
│   └── features/
│       ├── auth/
│       │   └── login_screen.dart        # Google Sign-In button
│       └── settings/
│           └── settings_screen.dart     # User info display
├── android/
│   └── app/
│       └── google-services.json         # ADD THIS FILE!
└── google-services-TEMPLATE.json        # Template for testing
```

## Common Issues

### "Sign-in failed"
**Fix**: Make sure `google-services.json` is in `android/app/`

### App crashes on startup
**Fix**: Check that package name in google-services.json matches `com.example.dishdiary`

### "No Google Play Services"
**Fix**: Use a physical device or emulator with Google Play Services

## Want to Remove Google Sign-In?

1. Edit `lib/features/auth/login_screen.dart` - remove Google button
2. Edit `pubspec.yaml` - remove `google_sign_in` dependency
3. Run `flutter pub get`
4. Done!

## Need Help?

Read `SIMPLE_GOOGLE_SIGNIN.md` for detailed setup instructions.

Read `IMPLEMENTATION_SUMMARY.md` for technical details.

---

**Remember**: This is authentication-only. All your recipe data stays local on your device!
