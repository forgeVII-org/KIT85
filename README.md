# KIT85
### 8085 Microprocessor Kit Simulator for Android

> A fully functional Intel 8085 kit simulator — built for students, educators, and electronics enthusiasts who want to learn, test, and experiment with 8085 assembly without physical hardware.

<br>

## Download

[![Download APK](https://img.shields.io/badge/Download-KIT85.apk-brightgreen?style=for-the-badge&logo=android)](https://github.com/forgeVII/KIT85/releases/latest)

> Requires Android 6.0+. Allow installation from unknown sources.

<br>

## What is KIT85?

Physical 8085 kits are expensive, fragile, and not always available. KIT85 brings the entire experience to your phone — same keyboard layout, same display behavior, same workflow. Write assembly, load it, run it, debug it — all on Android.

<br>

## Features

### Kit Mode
- Authentic 4×7 keyboard layout matching real 8085 kits
- 7-segment style red LED display (4-digit address + 2-digit data)
- Full EXMEM → NEXT memory editing flow
- GO → DOT execution flow
- Single Step (SI) with live PC tracking
- Examine & edit all registers (EXREG)
- FILL, Block Move, Memory Compare, String Search
- VCT / INT interrupt simulation
- SHIFT key for dual-function keys

### Assembler Mode
- Write 8085 assembly directly on your phone
- Two-pass assembler with forward label support
- Line numbers + syntax highlighting
- Hex output panel (address + bytes)
- Load assembled code directly into kit memory (→KIT)
- Supports ORG directive

### Tools
- **Disassembler** — live disasm panel with long-press jump
- **Memory Viewer** — full 64KB hex dump, auto bytes-per-row
- **Opcode Table** — LIST and GRID views matching physical opcode sheet
- **Number Converter** — live DEC ↔ HEX ↔ BIN ↔ OCT with 8-bit visual
- **Execution counter** — shows instructions executed after GO

### Built-in Reference Tools
Everything you need is inside the app — no internet, no external resources needed.

| Tool | Description |
|---|---|
| 📖 User Manual | Complete guide to every key, flow, and error code |
| 📊 Opcode Table | All 8085 opcodes in LIST view and GRID view (matches physical opcode sheet) |
| 🔢 Number Converter | Live DEC ↔ HEX ↔ BIN ↔ OCT with 8-bit visual |
| 🗂 Memory Viewer | Full 64KB hex dump with PC and address highlighting |
| ⚠️ Notices & Warnings | Explains all error codes, multi-step flows, and common mistakes |

> All tools accessible from the 3-dot menu — works completely offline.

### General
- Landscape support (wider editor in ASM mode)
- Copy address+data to clipboard (long press display)
- Zero external dependencies — pure Flutter

<br>

## Supported Instructions

All standard Intel 8085 instructions including:

`MOV` `MVI` `LXI` `LDA` `STA` `LHLD` `SHLD` `LDAX` `STAX` `XCHG`  
`ADD` `ADC` `SUB` `SBB` `ADI` `ACI` `SUI` `SBI` `INR` `DCR` `INX` `DCX` `DAD` `DAA`  
`ANA` `ORA` `XRA` `CMP` `ANI` `ORI` `XRI` `CPI` `CMA` `CMC` `STC`  
`RLC` `RRC` `RAL` `RAR`  
`JMP` `JNZ` `JZ` `JNC` `JC` `JP` `JM` `JPO` `JPE`  
`CALL` `CNZ` `CZ` `CNC` `CC` `CP` `CM` `RET` `RNZ` `RZ` `RNC` `RC` `RP` `RM`  
`PUSH` `POP` `XTHL` `SPHL` `PCHL`  
`RST 0–7` `EI` `DI` `NOP` `HLT` `RIM` `SIM` `IN` `OUT`

<br>

## How to Use

```
1. Install KIT85.apk on your Android device
2. Press EXMEM → type 4-digit address → press NEXT
3. Type data byte → press NEXT to save and advance
4. Press RESET when done entering data
5. Press GO → type start address → press DOT (•) to run
6. Check status bar for result
```

For assembler:
```
1. Tap ASM in the top bar
2. Write your 8085 assembly code
3. Press ASSEMBLE to see hex output
4. Press RUN to execute directly
   OR press →KIT to load into kit memory
```

<br>

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart) |
| External dependencies | None |
| Min Android | 6.0 (API 23) |
| Architecture | ARM64 |
| Package | com.prcnull.kit85 |

<br>

## Project Structure

```
lib/
├── cpu/              # 8085 CPU emulator + assembler
├── models/           # Enums (KitState, RegView)
├── screens/          # Main kit screen + splash
├── widgets/          # Display, keyboard, disasm, status bar, ASM view
├── sheets/           # Manual, opcode table, converter, memory viewer, about
└── constants.dart    # Colors, fonts, app constants
```

<br>

## Screenshots

> Coming soon

<br>

## Changelog

### v1.0.0
- Initial release
- Full 8085 CPU emulator
- Kit mode + ASM mode
- All tools included

<br>

## License

This project is for educational use.  
© 2026 forgeVII — All rights reserved.

<br>

---

<div align="center">
  Made by <a href="https://github.com/forgeVII">prcnull</a>
</div>
