# Google Sign-In + Google Drive Backup Guide

## What You Get Now

✅ **Google Sign-In** - Easy login with Google account
✅ **Local Storage** - All recipes stored on device (Isar DB) - works offline
✅ **Google Drive Backup** - Automatic backup to YOUR Google Drive
✅ **Restore Anytime** - Get your recipes back on any device
✅ **Privacy** - Backups stored in YOUR Drive, not on any server

## How It Works

### Storage Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Your Google Account                                    │
│  ├── Authentication (verifies who you are)             │
│  └── Google Drive                                       │
│      └── "DishDiary Backups" folder                     │
│          └── dishdiary_recipes_YYYYMMDDHHMMSS.xlsx     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Your Device (Local Isar Database)                      │
│  └── All your recipes (fast offline access)            │
└─────────────────────────────────────────────────────────┘
```

### Backup Process

1. **You click "Backup"** in Settings
2. **App creates Excel file** with all your recipes
3. **Uploads to YOUR Google Drive** → "DishDiary Backups" folder
4. **Shows success message** with last backup time

### Restore Process

1. **You click "Restore"** in Settings
2. **App finds latest backup** from your Google Drive
3. **Downloads Excel file** and parses recipes
4. **Adds all recipes** to your local database
5. **Shows count** of recipes restored

## Setup (Already Done!)

The `google-services.json` file is already in place at:
```
android/app/google-services.json
```

## How to Use

### First Time Login

1. Open app
2. Click **"Continue with Google"**
3. Select your Google account
4. You're logged in!

### Create Backup

1. Go to **Settings** (tap profile icon)
2. Scroll to **"Google Drive Backup"** section
3. Click **"Backup"** button
4. Confirm the dialog
5. ✅ Done! Your recipes are safe in Google Drive

### Restore Backup

1. Go to **Settings**
2. Scroll to **"Google Drive Backup"** section
3. Click **"Restore"** button
4. Confirm the dialog
5. ✅ Done! All recipes from backup are now on your device

### Check Backup Status

Look at the backup section in Settings:
- **Green box** = "Last backup: X time ago" ✅
- **Orange box** = "No backup yet" ⚠️

## Where Are My Backups Stored?

In your Google Drive:
```
Google Drive → "DishDiary Backups" folder → Excel files
```

You can view them:
1. Go to https://drive.google.com/
2. Look for "DishDiary Backups" folder
3. See your backup files (Excel format)

**Note**: Backups are in Excel format (.xlsx) - you can even open them on your computer!

## Important Notes

### What's Backed Up
- ✅ All recipes
- ✅ All ingredients
- ✅ All steps
- ✅ Nutritional info
- ✅ Categories and emojis

### What's NOT Backed Up
- ❌ AI API key (stored locally only)
- ❌ App settings (theme, etc.)

### Multiple Devices

You can use your recipes on multiple devices:

**Device 1** (Your phone):
1. Create recipes
2. Backup to Google Drive

**Device 2** (Your tablet):
1. Login with same Google account
2. Restore from Google Drive
3. All recipes appear!

### Privacy & Security

- ✅ Backups stored in YOUR Google Drive
- ✅ Only YOU can access them
- ✅ No third-party servers
- ✅ Encrypted connection (HTTPS)
- ✅ Excel format (standard, not proprietary)

## Troubleshooting

### "Not authenticated with Google"
**Fix**: Logout and login again with Google Sign-In

### "No backup files found"
**Fix**: This means you haven't created a backup yet. Click "Backup" first.

### "Backup failed"
**Possible causes**:
- No internet connection
- Google Drive storage full
- Google account permissions issue

**Fix**:
1. Check internet connection
2. Try again
3. If still fails, logout and login again

### "Restore failed"
**Possible causes**:
- No backup exists
- Corrupted backup file

**Fix**:
1. Check if backup exists in Google Drive
2. Create a new backup if needed

## Manual Backup (Optional)

Want extra safety? You can manually export:

1. Go to Settings → Google Drive Backup
2. Click "Backup"
3. This creates a NEW backup file (doesn't replace old ones)
4. You'll see multiple dated backups in Google Drive

## Delete Backup

Want to delete backups:

1. Go to https://drive.google.com/
2. Find "DishDiary Backups" folder
3. Delete files you don't want

**Warning**: This won't delete your local recipes, only the cloud backup!

## Technical Details

### Backup File Format
- **Format**: Excel (.xlsx)
- **Sheets**: 1 sheet named "Recipes"
- **Columns**: Recipe ID, Name, Category, Emoji, Ingredients (JSON), Steps (JSON), etc.

### Backup Naming
- **Format**: `dishdiary_recipes_YYYYMMDDHHMMSS.xlsx`
- **Example**: `dishdiary_recipes_20260313145630.xlsx`
- **Location**: Google Drive → "DishDiary Backups" folder

### Permissions Used
- `email` - Get your email for login
- `https://www.googleapis.com/auth/drive.file` - Create/manage backup files

## Rollback Plan

If anything goes wrong, your data is safe:

1. **Local data is preserved** - Backups don't affect local storage
2. **Multiple backups** - Each backup creates a new file
3. **Manual export** - You can always create new backups
4. **Excel format** - Backups can be read even without the app

## Summary

1. **Login** with Google
2. **Create** recipes (stored locally)
3. **Backup** to Google Drive (one click)
4. **Restore** anytime (one click)
5. **Your data is safe** - local + cloud backup!

---

**Need Help?** Check the troubleshooting section or review this guide.

**Want to see your backups?** Go to Google Drive → "DishDiary Backups" folder

**Lost your phone?** Just login on new device and restore! 🎉
