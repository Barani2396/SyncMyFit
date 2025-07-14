# SyncMyFit

A Swift-based iOS app to securely sync Fitbit data to Apple Health, ensuring reliable data tracking and control.

## 📱 About the App

**SyncMyFit** is a personal project developed to bridge the gap between Fitbit data and Apple Health. It syncs data like steps, heart rate, sleep, and calories directly from Fitbit’s API into Apple Health using a custom app identifier to track origin. While it's currently designed for personal use, future plans include advanced features like:

- 🔁 Auto Sync
- 🔔 Scheduled Notifications
- 📆 Historical Data Sync
- 🔒 Enhanced Privacy & Pro Access Features

## 🎨 UI and Design

- Custom-built **light** and **dark mode** compatibility.
- Dedicated **light/dark app icons**.
- Smooth transitions and state management for login/logout.
- Alert-driven confirmations before logout.
- Circular progress visualizations for each health metric.

## 🧪 Features

- Fitbit OAuth-based login flow.
- Secure token storage using Keychain.
- Displays last synced date and status.
- Animated dashboard with visual health metrics.
- User account view with profile image, display name, and logout.

## 📦 Tech Stack

- **SwiftUI**: Declarative UI framework.
- **Combine**: Reactive framework for sync status and app state.
- **HealthKit**: To write data into Apple Health.
- **Fitbit Web API**: For fetching fitness data.
- **Keychain**: Secure credential storage.
- **UserDefaults**: Persistent storage for sync timestamps.

## 🛠 Setup Instructions

If you'd like to run **SyncMyFit** with your own Fitbit Client ID:

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/SyncMyFit.git
    ```

2. Create a file called `Secrets.plist` at the project root level (`SyncMyFit/Secrets.plist`) with the following content:
    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>FitbitClientID</key>
        <string>YOUR_CLIENT_ID_HERE</string>
    </dict>
    </plist>
    ```

3. Open the project in Xcode and ensure:
    - `Secrets.plist` is added to your **main target membership**.
    - `Secrets.swift` (already present) is used to load this securely.

4. Make sure you’ve configured your Fitbit Developer App’s **redirect URI** and whitelisted necessary scopes (`activity`, `heartrate`, `sleep`, etc.).

5. Run the project on your iPhone (HealthKit requires a physical device).

## ✅ Current Version

**1.0.0** — First complete build, polished for personal use.

## 👨‍💻 Developed By

**Baranidharan Pasupathi**
