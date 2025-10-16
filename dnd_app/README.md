# dnd_app (Flutter starter)

This is a minimal Flutter workspace skeleton prepared for Android development on Windows. It includes a default Flutter app in `lib/main.dart` and instructions to generate platform files locally.

Important: I did not run `flutter create` here. To generate the Android project files and make the project runnable on an Android device or emulator, run the command shown below once you have Flutter and the Android tooling installed.

## Prerequisites
- Install Flutter SDK: https://docs.flutter.dev/get-started/install
- Install Android SDK / Android Studio and set up an Android Virtual Device (AVD)
- Ensure `flutter` is on your PATH

## Quick start (Windows PowerShell)

Open PowerShell and run:

```powershell
# Verify Flutter installation
flutter doctor

# Generate Android platform artifacts (run inside this project folder)
flutter create --platforms=android .

# Get dependencies
flutter pub get

# List emulators (optional)
flutter emulators

# Launch an emulator (replace <emulatorId> with one from the previous command)
flutter emulators --launch <emulatorId>

# Run the app on the default connected device/emulator
flutter run
```

## Open in VS Code

In PowerShell run:

```powershell
code "G:\\code\\dnd_app"
```

VS Code will recommend installing the Dart and Flutter extensions (see `.vscode/extensions.json`).

## Notes
- After you run `flutter create --platforms=android .` the `android/` directory will be populated with the standard Android project files. This repository currently contains a lightweight scaffold so you can inspect and edit Dart code immediately.
- If you want me to run `flutter create` and fully scaffold the Android native files, open this folder in VS Code and I can guide you through running that command locally (I can't execute it from here).