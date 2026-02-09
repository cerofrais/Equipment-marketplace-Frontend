# Build Configuration

## Prerequisites

### Java Version
- **Required:** Java 17 (LTS)
- **Location:** `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home`
- **Install:** `brew install openjdk@17`

The build script automatically sets `JAVA_HOME` to use Java 17.

### Android SDK Configuration
- **compileSdk:** 36
- **targetSdk:** 36
- **minSdk:** 21
- **ndkVersion:** 27.0.12077973
- **Java Version:** 17

## Build Script Usage

The [build.sh](build.sh) script provides automated building for different platforms:

```bash
./build.sh [android|android-bundle|web|both|all]
```

### Options

- **android** - Builds Android APK (release)
  - Output: `build/app/outputs/flutter-apk/app-release.apk`

- **android-bundle** - Builds Android App Bundle for Play Store (release)
  - Output: `build/app/outputs/bundle/release/app-release.aab`

- **web** - Builds Web App (release)
  - Output: `build/web/`

- **both** - Builds both Android APK and Web

- **all** - Builds everything (APK, App Bundle, and Web)

### Features

- Automatic Java 17 configuration
- Colored terminal output
- Automatic `flutter clean` and `flutter pub get`
- Error handling with exit codes
- Shows output locations

## GitHub Actions Workflow

The [.github/workflows/release-android.yml](.github/workflows/release-android.yml) workflow automatically:

1. Triggers on push to `main` branch (when PR is merged)
2. Can be manually triggered via `workflow_dispatch`
3. Builds Android APK in release mode
4. Extracts version from `pubspec.yaml`
5. Creates a GitHub Release with:
   - Tag format: `v{version}-build.{build_number}`
   - APK attached with clean filename
   - Detailed release notes
   - Installation instructions
6. Uploads APK as artifact (30-day retention)

### Release Naming

APK will be named: `equipverse-{version}-release.apk`

Example: `equipverse-1.0.0-release.apk`

## Example Usage

```bash
# Build Android APK
./build.sh android

# Build Web app
./build.sh web

# Build both platforms
./build.sh both

# Build everything including App Bundle
./build.sh all
```

## Troubleshooting

### Java Version Error

If you see errors about Java version 25 or invalid Java version format:
- The script automatically uses Java 17
- Ensure Java 17 is installed: `brew install openjdk@17`

### Gradle Build Failed

- Run `flutter clean` first
- Check that Android SDK and NDK are installed
- Verify Java 17 is being used

### Plugin SDK Warnings

If plugins require higher SDK versions, the build will still work but you may see warnings. Update `compileSdk`, `targetSdk`, and `ndkVersion` in [android/app/build.gradle.kts](android/app/build.gradle.kts) as needed.
