# Simplified Google Sign-In Setup for DishDiary

## What's Implemented

✅ **Google Sign-In Only** - Simple authentication without complex backend
✅ **100% Offline First** - All recipes stored locally in Isar DB
✅ **No Google Drive Backup** - Keep it simple, all data stays on device
✅ **Works Without Internet** - After login, app works completely offline

## Quick Setup (No Google Cloud Console Required!)

### Option 1: Use Pre-configured SHA-1 (For Testing Only)

For testing purposes, you can use a debug keystore. The app will work with any Google account.

**Steps:**

1. **Add google-services.json**:
   - I've included a template file
   - OR create a minimal one (see below)

2. **Create Minimal google-services.json**:
```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "dishdiary-test",
    "storage_bucket": "dishdiary-test.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abc123",
        "android_client_info": {
          "package_name": "com.example.dishdiary"
        }
      },
      "oauth_client": [
        {
          "client_id": "123456789-abc123.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

3. **Run the app**:
```bash
flutter clean
flutter pub get
flutter run
```

### Option 2: Proper Setup (For Production)

If you want to release the app properly:

1. **Create Google Cloud Project**:
   - Go to https://console.cloud.google.com/
   - Create new project: "DishDiary"

2. **Enable Google Sign-In API**:
   - APIs & Services → Library
   - Search "Google Sign-In API" → Enable

3. **Create OAuth Credentials**:
   - APIs & Services → Credentials
   - Create Credentials → OAuth Client ID
   - Application Type: Android
   - Package name: `com.example.dishdiary`
   - SHA-1: Run this command:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Download `google-services.json`

4. **Add to Project**:
   - Copy `google-services.json` to `android/app/`

5. **Build and Run**:
   ```bash
   flutter run
   ```

## How It Works

### Login Flow
```
User clicks "Continue with Google"
    ↓
Google Sign-In popup
    ↓
User selects Google account
    ↓
App creates user in LOCAL Isar DB
    ↓
User logged in - ALL DATA STORED LOCALLY
```

### Data Storage
```
┌─────────────────────────────────────┐
│  Google Account (Authentication)    │
│  - Just verifies who you are        │
│  - No data sent to Google           │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Local Isar Database (Your Data)    │
│  - All recipes                      │
│  - All ingredients                  │
│  - All steps                        │
│  - Works offline                    │
└─────────────────────────────────────┘
```

## Features

### What Google Knows:
- User logged in (authentication only)
- Email address
- Display name

### What Google DOESN'T Know:
- Your recipes
- Your ingredients
- Your cooking steps
- Any app data

### Offline Capability:
- ✅ View all recipes
- ✅ Create new recipes
- ✅ Edit recipes
- ✅ Delete recipes
- ✅ Use AI features (if API key configured)
- ❌ Google Sign-In (needs internet for initial login)

## Files Modified

### Core Changes:
- `lib/services/google_auth_service.dart` - Simple Google Sign-In
- `lib/services/auth_service.dart` - Added `signInWithGoogle()`
- `lib/features/auth/login_screen.dart` - Google Sign-In button
- `pubspec.yaml` - Added `google_sign_in` dependency

### Android Configuration:
- `android/app/build.gradle` - Google Services plugin
- `android/build.gradle` - Google Services classpath
- `android/app/src/main/AndroidManifest.xml` - Permissions

## Troubleshooting

### "Sign-in failed" Error
**Cause**: Missing or invalid `google-services.json`

**Fix**: 
1. Create proper google-services.json (Option 2 above)
2. OR use the template for testing

### App Crashes on Login
**Cause**: SHA-1 fingerprint mismatch

**Fix**:
1. Get your SHA-1:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Add it to Google Cloud Console
3. Download new google-services.json

### "No Google Play Services" Error
**Cause**: Emulator without Google Play Services

**Fix**:
- Use a physical device
- OR use an emulator with Google Play Store

## Rollback Plan

If you want to go back to email/password only:

1. **Remove Google Sign-In button**:
   - Edit `lib/features/auth/login_screen.dart`
   - Remove or comment out the Google Sign-In button section

2. **Remove dependency**:
   - Edit `pubspec.yaml`
   - Remove: `google_sign_in: ^6.1.6`
   - Run: `flutter pub get`

3. **Remove Google Services**:
   - Edit `android/app/build.gradle`
   - Remove: `id "com.google.gms.google-services"`
   - Edit `android/build.gradle`
   - Remove Google Services classpath

4. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Important Notes

1. **Local Storage**: All your recipes are stored locally in Isar database
2. **No Cloud Sync**: Changing devices means starting fresh (no cloud backup)
3. **Privacy**: Google only knows you logged in, not what you cook
4. **Offline**: After login, everything works without internet
5. **Simple**: No complex backend, no database servers, just local storage

## Next Steps

1. **Test the app**:
   ```bash
   flutter run
   ```

2. **Try Google Sign-In**:
   - Click "Continue with Google"
   - Select account
   - Create a recipe
   - Verify it's saved locally

3. **Verify offline mode**:
   - Turn off WiFi/mobile data
   - Open app
   - All recipes should be visible

## Support

If you need help:
1. Check this guide
2. Look at Flutter logs: `flutter run -v`
3. Verify google-services.json is in `android/app/`
4. Make sure SHA-1 is correct (if using Option 2)

---

**Summary**: Google Sign-In for authentication only. All data stays local. Works offline. No Google Drive backup complexity.
