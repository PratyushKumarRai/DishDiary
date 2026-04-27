# Google Sign-In & Drive Backup Setup Guide

## Overview
This guide explains how to set up Google Sign-In and Google Drive backup for your DishDiary app.

## Features Implemented
1. **Google Sign-In**: Users can now log in with their Google account
2. **Google Drive Backup**: Automatic backup of recipes to Google Drive in Excel format
3. **Restore from Backup**: Restore recipes from Google Drive backup
4. **Local Storage Preserved**: All existing local Isar storage remains intact

## Setup Instructions

### Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Name it something like "DishDiary"

### Step 2: Enable Required APIs

1. In the Google Cloud Console, go to **APIs & Services** > **Library**
2. Search for and enable the following APIs:
   - **Google Drive API**
   - **Google+ API** (for user info)

### Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** > **OAuth consent screen**
2. Select **External** user type (unless you have a Google Workspace account)
3. Fill in the required fields:
   - **App name**: DishDiary
   - **User support email**: Your email
   - **Developer contact email**: Your email
4. Click **Save and Continue**
5. Add scopes (optional for testing):
   - `email`
   - `https://www.googleapis.com/auth/drive.file`
6. Click **Save and Continue**
7. Add test users (your Google account)
8. Click **Save and Continue**

### Step 4: Create OAuth 2.0 Credentials

#### For Android:

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Select **Android** as the application type
4. Fill in:
   - **Name**: DishDiary Android
   - **Package name**: `com.example.dishdiary`
   - **SHA-1 certificate fingerprint**: 
     - For debug: Run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
     - For release: Use your release keystore SHA-1
5. Click **Create**
6. Download the OAuth client JSON file

#### For iOS (if needed):

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth client ID**
3. Select **iOS** as the application type
4. Fill in:
   - **Name**: DishDiary iOS
   - **Bundle ID**: `com.example.dishdiary`
5. Click **Create**
6. Download the plist file

### Step 5: Configure Android

1. Copy the downloaded `google-services.json` file to:
   ```
   dishdiary/android/app/google-services.json
   ```

2. The `build.gradle` files have already been updated with:
   - Google Services plugin in `android/app/build.gradle`
   - Google Services classpath in `android/build.gradle`

3. Required permissions are already added to `AndroidManifest.xml`

### Step 6: Configure iOS (if needed)

1. Open `ios/Runner/Info.plist`
2. Find the `CFBundleURLTypes` section
3. Replace `com.googleusercontent.apps.your-reverse-client-id` with your actual reverse client ID
   - Format: `com.googleusercontent.apps.{client-id}`
   - You can find this in the downloaded plist file from Google Cloud Console

### Step 7: Build and Run

```bash
flutter clean
flutter pub get
flutter run
```

## How to Use

### For Users:

1. **Login with Google**:
   - Open the app
   - Click "Continue with Google" button on login screen
   - Select your Google account
   - You're logged in!

2. **Backup Recipes**:
   - Go to Settings
   - Scroll to "Google Drive Backup" section (only visible for Google Sign-In users)
   - Click "Backup" button
   - Confirm the backup
   - Your recipes are now saved to Google Drive

3. **Restore Recipes**:
   - Go to Settings
   - Scroll to "Google Drive Backup" section
   - Click "Restore" button
   - Confirm the restore
   - Recipes from backup will be added to your local storage

### Backup File Location:
- Google Drive > "DishDiary Backups" folder > `dishdiary_recipes_backup.xlsx`

## Important Notes

1. **Local Storage**: Your existing local Isar database remains unchanged. Google Sign-In users still use local storage.

2. **Backup Format**: Recipes are stored in Excel format (.xlsx) which can be opened in any spreadsheet application.

3. **Security**: 
   - API keys and credentials are stored securely
   - Only the user has access to their Google Drive backup
   - No recipe data is sent to any external server except your Google Drive

4. **Multiple Devices**: 
   - Sign in with the same Google account on multiple devices
   - Backup from one device, restore on another

## Rollback Plan

If anything goes wrong, here's how to revert to the previous version:

### Option 1: Quick Rollback (Keep Current Code)

1. **Comment out Google Sign-In button** in `lib/features/auth/login_screen.dart`:
   ```dart
   // Comment out or remove the Google Sign-In button section
   ```

2. **Disable Backup UI** in `lib/features/settings/settings_screen.dart`:
   ```dart
   // Comment out the Google Drive Backup section
   ```

### Option 2: Full Rollback (Restore Previous Version)

If you have version control (Git):

```bash
# See what changed
git status

# Revert to previous commit
git reset --hard <commit-hash-before-changes>

# Or if you want to keep changes in a branch
git checkout -b google-signin-backup
git checkout main  # or your main branch
```

### Option 3: Manual File Restoration

Backup these files before making changes:
1. `pubspec.yaml` → `pubspec.yaml.backup`
2. `lib/services/auth_service.dart` → `auth_service.dart.backup`
3. `lib/features/auth/login_screen.dart` → `login_screen.dart.backup`
4. `lib/features/settings/settings_screen.dart` → `settings_screen.dart.backup`
5. `android/app/build.gradle` → `build.gradle.backup`
6. `android/build.gradle` → `build.gradle.root.backup`
7. `android/app/src/main/AndroidManifest.xml` → `AndroidManifest.xml.backup`

To restore:
```bash
# Copy backup files back
copy pubspec.yaml.backup pubspec.yaml
copy lib\services\auth_service.dart.backup lib\services\auth_service.dart
# ... and so on for each file

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Option 4: Disable Google Services (Keep Code)

If you want to keep the code but disable Google services:

1. **Remove dependencies** from `pubspec.yaml`:
   ```yaml
   # Comment out or remove:
   # google_sign_in: ^6.1.6
   # googleapis: ^12.0.0
   # googleapis_auth: ^1.4.1
   # excel: ^4.0.2
   # file_picker: ^6.1.1
   ```

2. **Remove Google Services plugin** from `android/app/build.gradle`:
   ```gradle
   // Comment out:
   // id "com.google.gms.google-services"
   ```

3. **Remove permissions** from `AndroidManifest.xml`:
   ```xml
   <!-- Remove Google-related permissions -->
   ```

4. Run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Troubleshooting

### Common Issues:

1. **"Sign-in failed" error**:
   - Check SHA-1 fingerprint is correct
   - Verify package name matches
   - Ensure OAuth consent screen is configured

2. **"No backup found"**:
   - Make sure you're signed in with the same Google account
   - Check if backup exists in Google Drive > "DishDiary Backups"

3. **Build errors**:
   - Run `flutter clean` and `flutter pub get`
   - Check if `google-services.json` is in the correct location

4. **"Drive API not enabled"**:
   - Go to Google Cloud Console
   - Enable Google Drive API

## Files Modified/Created

### New Files:
- `lib/services/google_auth_service.dart` - Google authentication
- `lib/services/google_drive_backup_service.dart` - Drive backup/restore
- `GOOGLE_SIGNIN_SETUP.md` - This guide

### Modified Files:
- `pubspec.yaml` - Added dependencies
- `lib/services/auth_service.dart` - Added Google Sign-In methods
- `lib/features/auth/login_screen.dart` - Added Google Sign-In button
- `lib/features/settings/settings_screen.dart` - Added backup/restore UI
- `android/app/build.gradle` - Added Google Services plugin
- `android/build.gradle` - Added Google Services classpath
- `android/app/src/main/AndroidManifest.xml` - Added permissions
- `ios/Runner/Info.plist` - Added URL schemes
- `lib/providers/providers.dart` - Added localStorageServiceAsyncProvider

## Support

If you encounter any issues:
1. Check the troubleshooting section above
2. Review Google Cloud Console configuration
3. Check Flutter logs for detailed error messages
4. Verify all setup steps are completed correctly
