---
name: flutter-build-release
description: Run the full Flutter build-and-release pipeline — analyze, fix errors, build APK/iOS, and push to remote.
---

# Flutter Build & Release Pipeline

Reusable workflow for preparing a Flutter app release. Handles the full cycle from code validation through to a pushed build artifact.

## Steps

### 1. Pre-flight check
- Run `flutter analyze 2>&1` from the project root.
- If there are errors, read the failing files, fix them, and re-run `flutter analyze` until clean.
- Do NOT build if `flutter analyze` has errors.

### 2. Build release APK
- Run `flutter build apk --release 2>&1`.
- If the build fails, read the error output, fix the root cause (Gradle, manifest, plugin compatibility), and re-run.
- After a successful build, report the APK path (typically `build/app/outputs/flutter-apk/app-release.apk`).

### 3. Build iOS (when requested)
- Run `open ios/Runner.xcworkspace` or `open -a Xcode ios/Runner.xcworkspace`.
- If `pod install` is needed, run `cd ios && pod install --repo-update`.
- For archive: `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive`.

### 4. Commit & push
- `git add -A && git commit -m "release: <brief description>"`
- `git push origin main`

### 5. Post-build verification
- For APK: confirm file exists at the reported path.
- For iOS: confirm Xcode opened without errors.

## Common issues & fixes

| Error | Fix |
|-------|-----|
| `flutter analyze` shows missing import | Add the import or run `flutter pub get` |
| Gradle build fails with SDK version | Update `android/app/build.gradle` `compileSdk` / `minSdk` |
| Plugin does not support Swift Package Manager | Run `cd ios && pod install --repo-update` or check `Podfile` |
| `JAVA_HOME` not set for Gradle | `export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home` |
| Gradle cache corruption | `rm -rf ~/.gradle/caches/9.1.0/transforms/` then retry |

## Stopping conditions

- Pipeline is complete after `git push` succeeds, OR
- If the user only asked for a specific step (e.g., "just build APK"), stop after that step.
