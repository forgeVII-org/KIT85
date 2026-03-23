import 'package:flutter/material.dart';
import '../constants.dart';

class NoticesSheet extends StatelessWidget {
  const NoticesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(top: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: kBorder, borderRadius: BorderRadius.circular(2))),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    color: kOrange, size: 17),
                const SizedBox(width: 8),
                const Text('Notices & Warnings',
                    style: TextStyle(
                        color: kText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ])),
          const Divider(color: kBorder, height: 1),
          Flexible(
              child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _section('STATUS / ERROR CODES', kRed, [
                _notice(Icons.error_outline, kRed, 'ERR:EXMEM',
                    'NEXT, PRE, or INS was used before entering EXMEM and confirming with NEXT. Run EXMEM -> enter address -> NEXT first.'),
                _notice(Icons.error_outline, kRed, 'ERR:GO',
                    'DOT (•) was pressed without GO mode. Press GO, enter start address, then press DOT.'),
                _notice(Icons.error_outline, kRed, 'ERR:ADDR',
                    'An operation needs a valid address input but address mode is not active or input is invalid.'),
                _notice(Icons.code, kOrange, 'ERR:ASM / ASM ERR',
                    'Assembler reported one or more line errors. Fix highlighted/source errors, then assemble again.'),
                _notice(Icons.info_outline, kBlueBright, 'INT:DIS',
                    'INT was triggered while interrupts were disabled. Ensure your program executes EI before INT.'),
                _notice(Icons.info_outline, kBlueBright, 'CANCEL',
                    'A running multi-step operation was interrupted by another incompatible action. Restart the intended flow from step 1.'),
              ]),
              _section('FLOW STATUS CODES', kBlueBright, [
                _notice(
                    Icons.tune,
                    kBlueBright,
                    'FILL:END / FILL:VAL / FILL:OK',
                    'FILL operation asks for end address, then value, then writes the selected range.'),
                _notice(
                    Icons.compare_arrows,
                    kBlueBright,
                    'BM:END / BM:DST / BM:OK',
                    'Block Move requests source end and destination, then copies source block to destination.'),
                _notice(
                    Icons.rule,
                    kBlueBright,
                    'MC:BLK2 / MC:LEN / MC:SAME / MC:DIFF',
                    'Memory Compare requests second block and length, then reports whether blocks match.'),
                _notice(Icons.search, kBlueBright, 'STR:VAL / STR:FND / STR:NF',
                    'String Search requests a byte value and scans memory from start address.'),
                _notice(Icons.bolt, kBlueBright, 'VCT:SET / INT:OK / INT:HLT',
                    'Interrupt vector set, then interrupt executed (or halted) when INT runs.'),
              ]),
              _section('DISASSEMBLER WARNINGS', kOrange, [
                _notice(
                    Icons.warning_amber_rounded,
                    kOrange,
                    'Data bytes may appear as opcodes',
                    'The disasm panel scans memory linearly. If data bytes are stored in code regions, they will be misread as instructions. This is a known limitation of linear disassembly.'),
                _notice(
                    Icons.info_outline,
                    kBlueBright,
                    'Disasm is for reference only',
                    'Always verify disassembled output against your known program. Long-press any disasm line to jump the address pointer to that location.'),
              ]),
              _section('KIT OPERATION REMINDERS', kBlueBright, [
                _notice(
                    Icons.touch_app,
                    kGreen,
                    'EXMEM must be used before NEXT/INS/PRE',
                    'After RESET, the display is off. You must press EXMEM, enter an address, then press NEXT to enter memory edit mode before using NEXT, PRE, or INS.'),
                _notice(Icons.touch_app, kGreen, 'GO then DOT(•) to execute',
                    'Press GO, type the start address, then press DOT(•) to run. Pressing DOT without GO first has no effect.'),
                _notice(
                    Icons.touch_app,
                    kGreen,
                    'SHIFT activates secondary key functions',
                    'Blue keys have two functions. Top label = normal. Bottom label = SHIFT function. Press SHF to toggle. Status bar shows SHIFT when active.'),
              ]),
              _section('MULTI-STEP OPERATIONS', kOrange, [
                _notice(Icons.linear_scale, kOrange, 'FILL requires 3 steps',
                    'Step 1: Set start address via EXMEM, press FILL (shows FILL:END). Step 2: Enter end address, press FILL (shows FILL:VAL). Step 3: Enter fill value, press FILL to execute.'),
                _notice(
                    Icons.linear_scale,
                    kOrange,
                    'B.M (Block Move) requires 3 steps',
                    'Step 1: Enter source start, press B.M. Step 2: Enter source end, press B.M. Step 3: Enter destination, press B.M to copy.'),
                _notice(Icons.linear_scale, kOrange, 'MEMC requires 3 steps',
                    'Step 1: Enter block 1 start, press MEMC. Step 2: Enter block 2 start, press MEMC. Step 3: Enter length, press MEMC. Result: MC:SAME or MC:DIFF.'),
                _notice(Icons.search, kBlueBright, 'STRING requires 2 steps',
                    'Step 1: Set search start address via EXMEM, press STRING. Step 2: Enter byte value to find, press STRING. Result: STR:FND (shows address) or STR:NF (not found).'),
                _notice(
                    Icons.cancel_outlined,
                    kTextDim,
                    'Pressing RESET cancels any active operation',
                    'If you are mid-flow in FILL, B.M, MEMC, or STRING, pressing RESET will cancel and return to clean state.'),
              ]),
              _section('MEMORY & CPU', kBlueBright, [
                _notice(
                    Icons.memory,
                    kBlueBright,
                    'Memory is 64KB (0000H–FFFFH)',
                    'The CPU has a flat 64KB address space. Address math wraps at FFFFH. Stack pointer defaults to FF00H after reset.'),
                _notice(
                    Icons.electric_bolt,
                    kGreen,
                    'CPU runs up to 100,000 steps per GO',
                    'To prevent infinite loops from hanging the app, execution is capped at 100,000 instructions. Use HLT to terminate programs cleanly.'),
                _notice(Icons.info_outline, kBlueBright, 'VCT/INT behavior',
                    'VCT stores the current address as the interrupt vector. INT fires only if EI was called (interrupts enabled). Status shows INT:DIS if interrupts are disabled.'),
              ]),
              _section('RECOVERY + BEST PRACTICES', kGreen, [
                _notice(Icons.restart_alt, kGreen, 'Recovery checklist',
                    'If flow gets stuck: RESET, re-enter EXMEM address, NEXT into DATA mode, then continue.'),
                _notice(Icons.layers, kGreen, 'Memory operation safety',
                    'Before FILL/B.M/MEMC/STRING, verify start addresses and lengths carefully to avoid unintentional overwrites.'),
                _notice(
                    Icons.settings_input_component,
                    kGreen,
                    'Interrupt vector setup',
                    'Set VCT to a valid service routine address, ensure routine ends safely, and call EI before INT testing.'),
                _notice(Icons.call_split, kGreen, 'Subroutine stack management',
                    'Initialize SP before CALL/RET usage and keep PUSH/POP balanced to prevent stack corruption.'),
              ]),
              _section('ASM MODE', kGreen, [
                _notice(
                    Icons.code,
                    kGreen,
                    'ORG directive sets the load address',
                    'Start your program with ORG XXXXH to set where it loads in memory. Default is 2000H if no ORG is specified.'),
                _notice(
                    Icons.arrow_forward,
                    kOrange,
                    '→KIT loads assembled code into kit memory',
                    'After assembling, use →KIT to pick a load address and transfer the code. The kit view will open with the program ready to run.'),
              ]),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _section(String title, Color color, List<Widget> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontFamily: kMono)),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      );

  Widget _notice(IconData icon, Color color, String title, String body) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: kMono)),
                const SizedBox(height: 3),
                Text(body,
                    style: const TextStyle(
                        color: kTextDim, fontSize: 11, height: 1.4)),
              ])),
        ]),
      );
}
