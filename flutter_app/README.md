# Cura Meal - Flutter Mobile App

This folder contains the complete Flutter mobile application source code.

## How to Run Independently

1. Ensure you have Flutter SDK installed (`flutter --version`).
2. Open terminal in this folder:
   ```bash
   cd flutter_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run on connected mobile device or emulator:
   ```bash
   flutter run
   ```
5. Build Android APK for distribution:
   ```bash
   flutter build apk --release
   ```

## Firebase Firestore Backend Sync
The app connects to the shared Firebase Firestore database so that registrations and placed orders reflect in real-time on the Admin panel.
