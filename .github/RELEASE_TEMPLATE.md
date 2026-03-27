## KIT85 v1.1.0

### Highlights
- Stronger converter input validation and bit limits
- Stricter assembler operand validation with clear error reporting
- New Tools and Settings UX split, including vibration toggle
- Sample Procedures guide with practical memory-value examples
- New 8-bit and 16-bit arithmetic sample programs

### What Changed
- Number Converter now blocks invalid characters and over-length values.
- Converter keeps fields empty when user fully deletes input.
- Assembler now reports invalid forms like MOV B or MOV 2000H, A.
- Added guided Sample Procedures screen in Tools.
- Added concrete beginner examples using memory address/value pairs.
- Added top sample programs for add/sub/mul/div (8-bit and 16-bit).

### Build Profile
- Platforms: Android + Web
- Android ABI: arm64
- Android hardened: obfuscation enabled, debug info split, icon tree-shaking enabled
- Web deployment: GitHub Pages

### Artifacts
- app-release.apk
- kit85-web-v1.1.0.zip

### Web
- Live URL: https://forgevii-org.github.io/KIT85/app/
- Web is now available and can be used on any platform (desktop, tablet, or mobile browser).

### Security Notes
- Signed with production key
- Symbols kept private and not included in release artifacts

### License
- GPL v3.0
- Source code available in this repository

### Known Limitations
- 16-bit multiply/divide samples are educational and loop-based, not cycle-optimized.

### Upgrade Notes
- Android users can install over older builds signed with the same release key.
- If upgrading from very old builds, clear app data once if unexpected state appears.
