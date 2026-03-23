# KIT85 Release Checklist

Use this checklist for every public Android release.

## 1. Versioning

- Update version in pubspec.yaml.
- Update in-app version string in lib/constants.dart.
- Commit version bump before building.

## 2. Signing Safety

- Ensure android/key.properties exists locally.
- Ensure key.properties points to your real production keystore.
- Confirm keystore and key.properties are never committed.

## 3. Quality Gate

Run:

flutter pub get
flutter analyze
flutter test

## 4. Build (Arm64, Hardened, Smallest Practical APK)

Run one-click script:

powershell -ExecutionPolicy Bypass -File tools/release-android-arm64.ps1

Expected output artifact:

build/app/outputs/flutter-apk/app-release.apk

## 5. Security Verification

- Verify signature output from apksigner in script output.
- Keep build/debug-info private.
- Do not upload debug symbols publicly.

## 6. Functional Smoke Test (Physical Device)

- Launch app and complete splash to main flow.
- Test assemble/load/run workflows.
- Open all sheets and dialogs.
- Test orientation behavior.
- Test update link behavior.

## 7. Publish

- Create GitHub release tag: vX.Y.Z
- Use .github/RELEASE_TEMPLATE.md for release notes.
- Attach arm64 APK.
- Add short changelog and known limitations.

## 8. GPLv3 Compliance

- Keep LICENSE in repository root.
- Keep source code available with distributed binaries.
- Document source location in release notes.
