# KIT85 Release Checklist

Use this checklist for every public release (Android and Web).

## 1. Versioning

- Update version in pubspec.yaml.
- Update in-app version string in lib/constants.dart.
- Commit version bump before building.
- Internal replacement build exception: for tiny non-public fixes, you may keep the same app version/code and replace only your private APK artifact (no new tag/release upload).

## 2. Signing Safety

- Ensure android/key.properties exists locally.
- Ensure key.properties points to your real production keystore.
- Confirm keystore and key.properties are never committed.

## 3. Quality Gate

Run:

flutter pub get
flutter analyze
flutter test

## 4. Build Android (Arm64, Hardened, Smallest Practical APK)

Run one-click script:

powershell -ExecutionPolicy Bypass -File tools/release-android-arm64.ps1

Expected output artifact:

build/app/outputs/flutter-apk/app-release.apk

## 5. Build Web (GitHub Pages)

Run:

powershell -ExecutionPolicy Bypass -File tools/release-web-pages.ps1

Expected staged output:

docs/app/

Expected live URL:

https://forgevii-org.github.io/KIT85/app/

Release note text to include: Web is now available and can be used on any platform (desktop, tablet, or mobile browser).

## 6. Security Verification

- Verify signature output from apksigner in script output.
- Keep build/debug-info private.
- Do not upload debug symbols publicly.

## 7. Functional Smoke Test

- Launch app and complete splash to main flow.
- Test assemble/load/run workflows.
- Verify assembler invalid operand warnings appear (example: MOV B, MOV 2000H,A).
- Open all sheets and dialogs.
- Verify menu categories:
	- Info: User Manual, Notices and Warnings, About
	- Tools: Number Converter, Opcode Table, Sample Procedures
	- Settings: Keyboard Vibration toggle
- Verify converter input validation:
	- BIN accepts only 0/1
	- HEX accepts valid hex (optional trailing H)
	- Empty delete state stays empty
- Open Sample Procedures and verify practical memory examples render.
- Test compact and wide/desktop browser layout behavior.
- Test update link behavior.

## 8. Publish

- Create GitHub release tag: vX.Y.Z
- Use .github/RELEASE_TEMPLATE.md for release notes.
- Attach arm64 APK (if Android release is included).
- Attach web artifact zip (kit85-web-vX.Y.Z.zip) below APK in the same release.
- Ensure docs/app is committed if web release is included.
- Add short changelog and known limitations.

## 9. GPLv3 Compliance

- Keep LICENSE in repository root.
- Keep source code available with distributed binaries.
- Document source location in release notes.
