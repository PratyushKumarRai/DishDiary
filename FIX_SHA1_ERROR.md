# Fix "ApiException: 10" - Google Sign-In Error

## The Problem

Error message:
```
Google Sign-In error: PlatformException(sign_in_failed, 
com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Error code 10** = **DEVELOPER_ERROR**
This means your app's SHA-1 fingerprint is NOT registered in Google Cloud Console.

## Solution - 3 Steps

### Step 1: Get Your SHA-1 Fingerprint

**Option A - Using Android Studio (Easiest)**

1. Open your project in **Android Studio**
2. Click **Terminal** tab (bottom)
3. Run this command:
   ```bash
   keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. Copy the **SHA1** value (looks like: `AA:BB:CC:DD:EE:FF:...`)

**Option B - Using the Script**

1. Run `get_sha1.bat` (I created it for you)
2. Copy the SHA1 value

**Option C - Manual Location**

Look for keytool in:
- `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`
- `C:\Program Files\Java\jdk\bin\keytool.exe`

Run it with the command from Option A.

### Step 2: Add SHA-1 to Google Cloud Console

1. Go to https://console.cloud.google.com/
2. Select your project (or create new one: "DishDiary")
3. Go to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client ID** (Android)
5. Click the **pencil icon** (edit)
6. Click **+ Add Fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

**Screenshot reference:**
```
OAuth 2.0 Client IDs
├── Your Android Client
│   ├── Package name: com.example.dishdiary
│   └── SHA-1 certificate fingerprint: AA:BB:CC:DD:EE:FF:... ← ADD HERE
```

### Step 3: Wait & Test

1. **Wait 2-5 minutes** (Google needs time to propagate changes)
2. **Uninstall the app** from your emulator/phone
3. **Rebuild and run**:
   ```bash
   flutter clean
   flutter run
   ```
4. Try Google Sign-In again

## Verification Checklist

- [ ] SHA-1 fingerprint added to Google Cloud Console
- [ ] Package name matches: `com.example.dishdiary`
- [ ] Waited at least 2 minutes after adding SHA-1
- [ ] Uninstalled old app version
- [ ] Rebuilt with `flutter clean`
- [ ] Google Play Services installed on device/emulator

## Still Not Working?

### Check Package Name

Make sure the package name in Google Cloud Console matches exactly:
- In `android/app/build.gradle`: `applicationId = "com.example.dishdiary"`
- In Google Cloud Console: Same package name

### Check google-services.json

1. After adding SHA-1, **download** the updated `google-services.json`
2. Replace the existing one in `android/app/`
3. Run `flutter pub get`

### Emulator Without Google Play Services

Some emulators don't have Google Play Services. Check:

**Android Studio Emulator:**
1. Open **Device Manager**
2. Check if your emulator has **Play Store** icon
3. If not, create a new device with Play Store

**Or use a physical device** for testing.

### Create New OAuth Client (If Needed)

If you don't have an Android OAuth client:

1. Go to **APIs & Services** → **Credentials**
2. **Create Credentials** → **OAuth Client ID**
3. Application type: **Android**
4. Package name: `com.example.dishdiary`
5. SHA-1: (paste your fingerprint)
6. Click **Create**
7. Download `google-services.json`

## Debug vs Release SHA-1

For **debug/testing**, use the debug keystore SHA-1 (what we're doing now).

For **production/release**, you'll need the release keystore SHA-1:
```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-alias -storepass your-password
```

## Quick Summary

```
Error 10 = SHA-1 not registered

Fix:
1. Get SHA-1 fingerprint (keytool command)
2. Add to Google Cloud Console → Credentials → Your OAuth Client
3. Wait 2-5 minutes
4. Uninstall app, rebuild, run
5. Should work now!
```

## Need More Help?

1. Check exact error in logs: `flutter run -v`
2. Verify SHA-1 in Google Cloud Console matches exactly
3. Make sure you're using the right OAuth client (Android, not Web)
4. Try on a physical device if emulator has issues

---

**TL;DR**: Get SHA-1 → Add to Google Cloud → Wait → Rebuild → Works! ✅
