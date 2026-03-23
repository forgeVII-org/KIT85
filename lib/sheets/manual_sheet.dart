import 'package:flutter/material.dart';
import '../constants.dart';

class ManualSheet extends StatelessWidget {
  const ManualSheet({super.key});

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, sc) => SafeArea(
          child: Container(
            decoration: const BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
            child: Column(children: [
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: kBorder, borderRadius: BorderRadius.circular(2))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(children: [
                    const Icon(Icons.menu_book, color: kBlueBright, size: 17),
                    const SizedBox(width: 8),
                    const Text('User Manual',
                        style: TextStyle(
                            color: kText,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ])),
              Expanded(
                  child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      children: [
                    _sec('GETTING STARTED', [
                      'On launch, a short tube-light splash plays (ON -> OFF -> ON, about 2s), then KIT mode opens automatically.',
                      'Main view in portrait: Disassembler panel, toggle, display, status bar, keyboard.',
                      'Landscape view: disassembler is pinned on the left for side-by-side debugging.',
                      'Use the top-right menu (⋮) for Manual, Opcode Table, Converter, Notices, and About.',
                    ]),
                    _sec('DISPLAY BASICS', [
                      'Left 4 digits = address. Right 2 digits = data byte.',
                      'Dim dashes mean the side is currently inactive for input.',
                      'When execution finishes, the address side can show E state via status and execution flag.',
                      'Long-press the display to copy "ADDR DATA" to clipboard.',
                    ]),
                    _sec('KIT MODE: CORE FLOW', [
                      'RESET: clears CPU state, exits active flows, turns SHIFT off, and returns to safe idle.',
                      'EXMEM (SHIFT on REL key): enters address entry mode (ADDR>). Enter 4 hex digits.',
                      'NEXT after EXMEM: confirms address, enters DATA> edit mode, and enables memory operations.',
                      'INS: saves data and advances to next address. NEXT also saves-and-advance while memory mode is active.',
                      'PRE: saves data and goes back one address.',
                      'DEL: removes one typed nibble from current address/data entry.',
                      'If NEXT/PRE/INS are used before EXMEM→NEXT activation, status shows ERR:EXMEM.',
                    ]),
                    _sec('KIT MODE: EXECUTION', [
                      'GO: starts run setup (GO>). Enter start address.',
                      'DOT (•): executes from GO address until HLT or safety cap (100,000 steps).',
                      'Status becomes HALT (N) or DONE (N), where N is executed instruction count.',
                      'DOT without GO shows ERR:GO.',
                      'SI (SHIFT + EXREG): single-instruction step from current address; status shows STEP or HALT.',
                    ]),
                    _sec('KIT MODE: REGISTERS + SHIFT', [
                      'EXREG: opens register view REG:<name>.',
                      'NEXT/PRE cycle: A, B, C, D, E, H, L, SP, PC, F.',
                      'Type hex to edit selected register (8-bit or 16-bit width is handled automatically).',
                      'SHF toggles alternate key functions. Status shows SHIFT when active.',
                    ]),
                    _sec('KIT MODE: ADVANCED OPS', [
                      'FILL (3-step): start address -> end address -> value, then writes range and shows FILL:OK.',
                      'B.M Block Move (3-step): source start -> source end -> destination, then shows BM:OK.',
                      'MEMC Compare (3-step): block1 -> block2 -> length, then MC:SAME or MC:DIFF.',
                      'STRING Search (2-step): start address -> byte value, then STR:FND or STR:NF.',
                      'VCT stores current address as interrupt vector (VCT:SET). INT executes one interrupt step from that vector.',
                      'INT requires EI in your program; otherwise status shows INT:DIS.',
                      'REL currently shows RELOCATE status only (UI placeholder, no relocation flow yet).',
                      'Starting one multi-step operation while another is active cancels the previous flow (CANCEL).',
                    ]),
                    _sec('ASM MODE: EDITOR + ACTIONS', [
                      'Switch using ASM/KIT button in app bar.',
                      'Editor supports synchronized line numbers, syntax highlighting, and inline comments with semicolon (;).',
                      'Line numbers always show one extra trailing line so you can start typing on the next line immediately.',
                      'ASSEMBLE: parses/assembles and updates right-side hex preview.',
                      'RUN: assembles and executes from detected ORG (default 2000H).',
                      'CLEAR: clears source and output.',
                      'SAMPLES: opens the sample programs library (acts as "Load Program").',
                      '→ KIT: choose load origin, write bytes to memory, and return to KIT mode ready to run.',
                    ]),
                    _sec('ASM SYNTAX HIGHLIGHTING', [
                      'Blue = opcodes (for example MOV, MVI, JMP, CALL).',
                      'Green = labels (tokens ending with ":").',
                      'Gray = comments (everything after ;).',
                      'Orange = numbers/hex literals (10, 0AH, 2000H, 0x20).',
                      'Purple = registers (A, B, C, D, E, H, L, M, SP, PC, F).',
                      'Teal = directives (ORG, DB, DW, DS, END, DEFINE).',
                    ]),
                    _sec('SAMPLE PROGRAMS LIBRARY (10)', [
                      'Use SAMPLES in ASM mode, pick an entry, then modify and run it like normal source.',
                      'Counter (0-255): increments A until overflow.',
                      'Add Two Numbers: adds B and C, stores result to memory.',
                      'Factorial (5!): demonstrates loops + subroutine multiplication.',
                      'Clear Memory Block: writes 00H across 16 bytes.',
                      'Rotate Register A: applies RLC repeatedly.',
                      'Compare and Jump: branch decisions using CMP/JC/JZ.',
                      'Stack Operations: PUSH/POP behavior with SP setup.',
                      'Copy Memory Block: HL source to DE destination copy loop.',
                      'Binary to BCD: repeated subtraction conversion example.',
                      'Call Subroutine: minimal CALL/RET workflow.',
                    ]),
                    _sec('DISASSEMBLER PANEL', [
                      'Shows nearby decoded instructions around current address.',
                      'Current row is highlighted; long-press a row to jump address pointer there.',
                      'Linear disassembly can interpret raw data as opcodes, so treat output as a guide.',
                    ]),
                    _sec('TOOLS / UTILITIES', [
                      'Opcode Table: two tabs (LIST and GRID) for quick mnemonic-to-opcode reference.',
                      'Number Converter: live DEC/HEX/BIN/OCT conversion with 8-bit bit-view.',
                      'Notices & Warnings: centralized error/status explanations and recovery tips.',
                      'About: version, project links, capability summary, and credits.',
                    ]),
                    _sec('UPDATE CHECKER', [
                      'App checks GitHub releases shortly after KIT screen opens.',
                      'If newer version is found, dialog opens and DOWNLOAD button sends you to Releases page.',
                      'Updates are manual download/install; in-app auto-install is not performed.',
                    ]),
                    _sec('TIPS & TROUBLESHOOTING', [
                      'Common run path: RESET -> EXMEM/NEXT load bytes -> GO + address -> DOT.',
                      'For repeated editing, keep memory mode active and use NEXT/PRE for fast navigation.',
                      'Use SAMPLES as templates: load, tweak constants/labels, ASSEMBLE, then RUN or → KIT.',
                      'If a key seems ignored, check whether SHIFT mode or a multi-step flow is currently active.',
                      'If interrupts fail, verify your code executed EI before INT.',
                      'Use landscape for larger disassembly context while stepping or debugging.',
                    ]),
                  ])),
            ]),
          ),
        ),
      );

  Widget _sec(String title, List<String> pts) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kBlue.withValues(alpha: 0.5)),
            ),
            child: Text(title,
                style: const TextStyle(
                    color: kBlueBright,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: kMono)),
          ),
          const SizedBox(height: 6),
          ...pts.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: kBlueBright, fontSize: 12)),
                      Expanded(
                          child: Text(p,
                              style: const TextStyle(
                                  color: kTextDim, fontSize: 12, height: 1.4))),
                    ]),
              )),
        ],
      );
}
