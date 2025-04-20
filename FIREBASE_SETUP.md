# Firebase Setup Instructions for Hortimize

Follow these steps to complete the Firebase setup for your Hortimize Flutter application:

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project"
3. Enter a project name (e.g., "Hortimize")
4. Follow the on-screen instructions to create the project

## Step 2: Register your app with Firebase

### For Android:

1. In the Firebase console, click "Add app" and select the Android platform
2. Enter your Android package name (found in `android/app/build.gradle` under `applicationId`)
3. Register the app
4. Download the `google-services.json` file
5. Place the file in the `android/app/` directory of your Flutter project

### For iOS:

1. In the Firebase console, click "Add app" and select the iOS platform
2. Enter your iOS bundle ID (found in Xcode under the "General" tab for your target)
3. Register the app
4. Download the `GoogleService-Info.plist` file
5. Open Xcode, right-click on the Runner folder, and select "Add Files to 'Runner'"
6. Select the downloaded `GoogleService-Info.plist` file and add it to your project

## Step 3: Additional Android Configuration

1. Modify your `android/build.gradle` file to include the Google Services plugin:

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

2. Modify your `android/app/build.gradle` file to apply the plugin:

```gradle
// Add this line at the bottom of the file
apply plugin: 'com.google.gms.google-services'
```

## Step 4: Additional iOS Configuration

1. Add the Firebase initialization code to your `ios/Runner/AppDelegate.swift` file:

```swift
import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 5: Run your app

After completing these steps, you can run your app with Firebase integration:

```
flutter run
```

## Troubleshooting

- Make sure all the Firebase configuration files are in the correct locations
- Ensure you've added all required dependencies in the `pubspec.yaml` file
- If you encounter any issues, check the Firebase documentation and Flutter Firebase plugin documentation for more details

## Note

The Firebase setup has already been integrated into the Flutter code with the necessary dependencies and initialization code. You just need to follow the steps above to connect your app to a Firebase project. 