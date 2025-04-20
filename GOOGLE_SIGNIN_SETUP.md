# Setting Up Google Sign-In for Hortimize

To enable Google Sign-In in your Hortimize app, follow these steps in the Firebase console:

## 1. Configure Google Sign-In in Firebase Console

1. Go to the [Firebase Console](https://console.firebase.google.com/) and select your project.
2. In the left sidebar, click on **Authentication**.
3. Click on the **Sign-in method** tab.
4. Find **Google** in the list of providers and click on it.
5. Click the toggle to **Enable** Google Sign-In.
6. Enter your **Project support email** (usually your Google account email).
7. Click **Save**.

## 2. Configure SHA Certificate Fingerprints (Android)

For Android, you need to add SHA certificate fingerprints:

1. In the Firebase Console, go to **Project settings** (gear icon near the top of the sidebar).
2. Scroll down to **Your apps** and select your Android app.
3. Click **Add fingerprint**.

### Generate SHA-1 Certificate

To generate your SHA-1 fingerprint:

#### Debug Certificate (for development)

```bash
# For macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# For Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Release Certificate (for production)

```bash
keytool -list -v -keystore /path/to/your/release/keystore.jks -alias your-key-alias
```

4. Copy the SHA-1 certificate fingerprint from the terminal output.
5. Paste it into the Firebase console and click **Save**.

## 3. Update Google Services Files

After making these changes in the Firebase Console:

1. Download the updated `google-services.json` for Android.
2. Replace the existing file in your `android/app/` directory.
3. For iOS, download the updated `GoogleService-Info.plist` file and replace it in your iOS project.

## 4. Add Google Logo

For the Google Sign-In button:

1. Download the Google logo from [Google Identity Branding Guidelines](https://developers.google.com/identity/branding-guidelines).
2. Save it as `google_logo.png` in the `asset/images/` directory of your project.

## 5. Testing Google Sign-In

When testing:

- Use real devices or emulators with Google Play Services.
- Make sure the test device has a Google account set up.
- Clear app data if you encounter persistent issues.

## Troubleshooting

- **"Sign in failed, No user found"**: Verify SHA-1 fingerprint is correctly added to Firebase.
- **"Developer error" on Android**: Check that the SHA-1 fingerprint matches your debug/release keystore.
- **Web API key error**: Make sure the correct `google-services.json` file is in your project.

For more information, see the [Firebase Authentication documentation](https://firebase.google.com/docs/auth/android/google-signin). 