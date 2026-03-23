# KIT85

KIT85 is a modern Flutter-based 8085 microprocessor simulator built for students, hobbyists, and educators.

It aims to provide a clean, practical environment to experiment with 8085 workflows while keeping the app lightweight and easy to run.

## Why KIT85

- Student-friendly interface for 8085 practice
- Fast startup and responsive controls
- Cross-platform Flutter codebase
- Open source and free to use

## Features

- 8085 simulator core and assembler workflow
- Ready-to-use sample programs
- Opcode reference and converter utilities
- Retro-inspired UI tuned for readability
- In-app update check for new releases

## Tech Stack

- Flutter (Dart)
- Android, iOS, Web, Desktop targets

## Quick Start

### Prerequisites

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)

### Run locally

```bash
flutter pub get
flutter analyze
flutter run
```

## Build Release APKs (Recommended)

The project is configured for a hardened and size-optimized Android release flow.

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

Output APKs are generated in `build/app/outputs/flutter-apk/`.

## Android Signing Setup

Release signing is configured in `android/app/build.gradle.kts` and reads credentials from `android/key.properties`.

1. Create or place your keystore file (example: `android/upload-keystore.jks`).
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill values:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

Notes:

- `storeFile` is resolved from the `android/app` module directory.
- `android/.gitignore` excludes keystore material and `key.properties`.

## Versioning

Update both before release:

- `pubspec.yaml` -> `version:`
- `lib/constants.dart` -> `kAppVersion`

## Release Checklist

1. Update app version.
2. Ensure signing config is valid.
3. Run checks:

```bash
flutter analyze
flutter test
```

4. Build release artifacts.
5. Smoke-test on a physical device.
6. Upload APKs and symbol files with release notes.

## Repository Standards

- License: MIT (`LICENSE`)
- Contribution guide: `CONTRIBUTING.md`
- Code of conduct: `CODE_OF_CONDUCT.md`
- Changelog: `CHANGELOG.md`

## Roadmap

- More teaching-oriented sample programs
- Better diagnostics and error explanations
- Additional emulator quality-of-life tools

## Maintainer

- Organization: `forgeVII-org`
- Repository: `KIT85`

## Acknowledgements

Built with Flutter and made open for the student community.
