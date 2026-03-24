# kit85

A free and open-source 8085 simulator for students, educators, and hobbyists.

KIT85 is an 8085 microprocessor simulator for Android where you can write,
assemble, and run 8085 assembly programs in a student-friendly workflow.

- Download APK: https://github.com/forgeVII-org/KIT85/releases
- Source code (GPL v3.0): https://github.com/forgeVII-org/KIT85
- Platforms: Android + Web
- Web app: https://forgevii-org.github.io/KIT85/app/

Web is now available and can be used on any platform (desktop, tablet, or mobile browser).

Keywords: 8085 simulator, 8085 microprocessor simulator,
8085 simulator for Android, 8085 simulator web.

## Getting Started

```bash
flutter pub get
flutter run
```

Run on web locally:

```bash
flutter run -d chrome
```

## Disassembler behavior

- When program bytes are loaded from ASM, disassembly is ASM-guided.
- Known instruction-start addresses are decoded as instructions.
- Other addresses are shown as DATA to avoid false opcode interpretation.
- In manual-only memory sessions (no ASM metadata), disassembly falls back to linear decoding.

## Android release signing

Release signing is configured in `android/app/build.gradle.kts` to use
`android/key.properties` when present.

If `android/key.properties` is missing or incomplete, release builds fail by
design to prevent accidental debug-signed production artifacts.

### Setup steps

1. Create or place your keystore file (example: `android/upload-keystore.jks`).
2. Copy `android/key.properties.example` to `android/key.properties`.
3. Fill `android/key.properties` with your actual values:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
```

Notes:

- `storeFile` is resolved from the `android/app` module directory.
- `android/.gitignore` already excludes `key.properties` and keystore files.

### Build commands

```bash
flutter analyze
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

### One-click production release (arm64 only)

For modern Android phones and smallest distribution size:

```powershell
powershell -ExecutionPolicy Bypass -File tools/release-android-arm64.ps1
```

This script runs analysis, builds a hardened arm64 release APK, and prints
artifact size and path.

## Web release (GitHub Pages)

The web app is published under:

`https://forgevii-org.github.io/KIT85/app/`

The current web build is cross-platform and ready for use on any device with a modern browser.

Build and stage a web release into `docs/app`:

```powershell
powershell -ExecutionPolicy Bypass -File tools/release-web-pages.ps1
```

Then commit `docs/app` and push to `main` (with Pages configured to `main` +
`/docs`).

## Release checklist

Use this list before cutting a public release.

Detailed checklist file:

- RELEASE_CHECKLIST.md

1. Update versions in both places:
	- `pubspec.yaml` -> `version:`
	- `lib/constants.dart` -> `kAppVersion`
2. Ensure `android/key.properties` exists with real signing values.
3. Run quality checks:

```bash
flutter analyze
flutter test
```

4. Build hardened release APKs (smaller per-device files):

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

Alternative for smallest single Android artifact (arm64 only):

```bash
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=build/debug-info --tree-shake-icons
```

5. Smoke-test on device:
	- Launch app and confirm splash -> kit flow.
	- Open all bottom sheets and check no status/nav-bar clipping.
	- Rotate to landscape and verify layout remains usable.
	- Trigger update check and confirm DOWNLOAD opens:
	  `https://github.com/forgeVII-org/KIT85/releases`

6. Archive outputs:
	- APKs from `build/app/outputs/flutter-apk/`
	- Symbols from `build/debug-info/`

7. Build and verify web release:
	- Run `powershell -ExecutionPolicy Bypass -File tools/release-web-pages.ps1`
	- Open `https://forgevii-org.github.io/KIT85/app/` and validate desktop + mobile layout.

## Security and anti-theft notes

No APK can be made impossible to copy or reverse engineer. This project already
uses practical hardening for Android release builds:

- R8 code shrinking/optimization (`isMinifyEnabled = true`)
- Resource shrinking (`isShrinkResources = true`)
- Dart obfuscation (`--obfuscate --split-debug-info=...`)
- Split APKs per ABI (`--split-per-abi`) to reduce distributed size

For open-source distribution, treat code transparency as expected and focus on:

- Strong release signing key hygiene (never commit keystore or key.properties)
- Publishing only signed release APKs
- Keeping `build/debug-info/` private for crash symbolization
- Verifying APK signature before upload (`apksigner verify --print-certs <apk>`)

## License

This project is licensed under GNU GPL v3.0.

- Full text: `LICENSE`
- SPDX identifier: `GPL-3.0-only`

GPLv3 requires derivative works that are distributed to also provide source
under GPL-compatible terms.

## GitHub Release Notes Template

Use .github/RELEASE_TEMPLATE.md when publishing each tagged release.

## Student Discovery (Google + Web)

A search-optimized landing page is available in `docs/` for GitHub Pages.

Enable it:

1. GitHub -> Settings -> Pages
2. Source: Deploy from a branch
3. Branch: `main` / Folder: `/docs`

After publishing, your landing URL will be:

`https://forgevii-org.github.io/KIT85/`

