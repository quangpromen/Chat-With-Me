## Copilot / AI agent instructions for chat_offline

Short goal
- Help developers make small, safe changes to the Flutter app located in `lib/` and related platform folders. Prefer minimal, testable edits and keep generated platform files untouched.

Big picture (what this repo is)
- A standard Flutter app using stable Flutter + Dart (see `pubspec.yaml`, sdk ^3.9.2). Entrypoint: `lib/main.dart`.
- Multi-platform project: `android/` (Kotlin-DSL Gradle), `ios/`, `linux/`, `macos/`, `windows/`, `web/`. Platform-specific glue and generated plugin registrants live under each platform folder (do not edit generated files unless necessary).

How to run / build / test (concrete commands)
- Fetch deps: `flutter pub get` (run from project root).
- Run app (debug) on default device: `flutter run`.
- Run on Windows desktop explicitly: `flutter run -d windows`.
- Android build (Windows PowerShell): `cd android; .\gradlew.bat assembleDebug` then back to root.
- iOS: open `ios/Runner.xcworkspace` in Xcode for signing and device selection. Use `flutter build ios` for CI/macOS shell builds.
- Run tests: `flutter test` (will run tests under `test/`, e.g. `test/widget_test.dart`).
- Analyze/lint: `flutter analyze` and follow `analysis_options.yaml` rules (`flutter_lints` is enabled in `pubspec.yaml`).

Project-specific patterns and conventions
- Null-safety and modern Dart: SDK >=3; use non-nullable types by default. Keep constructors and widgets `const` when possible (example: `MyApp` in `lib/main.dart`).
- Minimal starter app scaffolding: the UI is a single StatefulWidget (`MyHomePage`) — look for patterns there when adding features that need local state.
- Assets: none configured in `pubspec.yaml` by default. If adding assets, update `flutter:` -> `assets:` in `pubspec.yaml` and reference them from `lib/`.
- Lints: follow `analysis_options.yaml`. When adding code, fix analyzer warnings before creating a PR.

Files to inspect when making cross-cutting changes
- App entry: `lib/main.dart` (root widget, theme, home screen).
- Dependencies and SDK: `pubspec.yaml`.
- Lint/config: `analysis_options.yaml`.
- Android specifics: `android/app/build.gradle.kts`, `android/local.properties` (SDK path), `android/gradlew(.bat)`.
- iOS specifics: `ios/Runner/Info.plist`, `ios/Runner.xcodeproj` and `ios/Runner.xcworkspace` for signing.
- Tests: `test/widget_test.dart`.

Integration notes and generated code
- Generated plugin registrant files are present under each platform (e.g., `ios/Flutter/Generated.xcconfig`, `linux/flutter/generated_plugin_registrant.cc`, `windows/flutter/generated_plugin_registrant.cc`). Avoid editing generated files; instead, add native plugins via `pubspec.yaml` or platform-specific plugin setup steps.

When you change dependencies
- Run `flutter pub get` and ensure `pubspec.lock` updated. If adding native plugins, ensure platform files are updated and run a platform build (`flutter build apk` or open Xcode) to verify native integration.

What to avoid/important constraints
- Don't modify generated platform files unless explicitly required (they are in platform-specific `flutter/` subfolders or `GeneratedPluginRegistrant.*`).
- Avoid changing top-level build scripts (Gradle wrapper, Xcode project) unless the change is necessary and you can validate on CI or corresponding platform.

Example tasks with concrete steps
- Add a new package (example `http`):
  1. `flutter pub add http`
  2. Update imports in `lib/` and add a small unit/widget test in `test/`.
  3. Run `flutter test` and `flutter analyze`.

- Small UI change (e.g., change title text):
  1. Edit `lib/main.dart` → `MyHomePage(title: 'New Title')`.
  2. Run `flutter run` and hot-reload (`r`) to verify.

If anything is unclear
- Ask for the intended platform(s) to validate (mobile vs desktop vs web). If a native signing or SDK path is required (Android SDK or Xcode), request credentials or environment specifics.

Where this file is referenced
- This file should live at `.github/copilot-instructions.md`. Keep it concise; update when repo structure or platform choices change.

Thanks — ask me for specifics (which platform to validate on, or where to open a PR).
