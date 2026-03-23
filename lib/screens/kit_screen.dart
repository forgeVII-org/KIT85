import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../cpu/cpu_8085.dart';
import '../cpu/assembler_8085.dart';
import '../models/enums.dart';
import '../widgets/hex_display.dart';
import '../widgets/keyboard.dart';
import '../widgets/disasm_panel.dart';
import '../widgets/status_bar.dart';
import '../widgets/asm_view.dart';
import '../sheets/manual_sheet.dart';
import '../sheets/opcode_sheet.dart';
import '../sheets/converter_sheet.dart';
import '../sheets/about_sheet.dart';
import '../utils/update_checker.dart';
import '../sheets/notices_sheet.dart';

class KitScreen extends StatefulWidget {
  const KitScreen({super.key});
  @override
  State<KitScreen> createState() => KitScreenState();
}

class KitScreenState extends State<KitScreen> {
  static const int kAsmMaxSourceLines = 4000;
  static const int kMemorySize = 0x10000;

  final cpu = CPU8085();
  final asmEngine = Assembler8085();

  int addrBuf = 0, dataBuf = 0, inputDigits = 0;
  bool shifted = false;
  String status = 'RESET';
  bool asmMode = false, disasmVisible = true;
  bool addrOn = false, dataOn = false, execDone = false;

  KitState kstate = KitState.idle;
  RegView regView = RegView.a;

  final asmCtrl = AsmSyntaxController(
    text: '; 8085 Assembler\nORG 2000H\n\nMVI A, 05H\nMVI B, 03H\nADD B\nHLT\n',
  );
  List<AsmLine> asmLines = [];
  String asmError = '';
  int asmOrigin = 0x2000;

  List<Map<String, dynamic>> disasmCache = [];
  int lastDisasmAddr = -1;

  // ── multi-step op state ───────────────────────────────────────────────────
  int _fillStart = 0, _fillStep = 0;
  int _bmSrc = 0, _bmEnd = 0, _bmStep = 0;
  int _mcBlk1 = 0, _mcBlk2 = 0, _mcStep = 0;
  int _strStart = 0, _strStep = 0;
  int _vctAddr = 0x003C;
  bool _memActive = false;

  bool get _inFlow =>
      _fillStep > 0 || _bmStep > 0 || _mcStep > 0 || _strStep > 0;

  @override
  void initState() {
    super.initState();
    // check for updates 3 seconds after kit screen loads
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) UpdateChecker.check(context);
    });
  }

  @override
  void dispose() {
    asmCtrl.dispose();
    super.dispose();
  }

  // ── disasm cache ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> getDisasm() {
    if (lastDisasmAddr != addrBuf) {
      disasmCache = _disasm(addrBuf, 10, 20);
      lastDisasmAddr = addrBuf;
    }
    return disasmCache;
  }

  void invalidateDisasm() => lastDisasmAddr = -1;

  // ── register helpers ──────────────────────────────────────────────────────
  int getRegVal(RegView r) {
    switch (r) {
      case RegView.a:
        return cpu.a;
      case RegView.b:
        return cpu.b;
      case RegView.c:
        return cpu.c;
      case RegView.d:
        return cpu.d;
      case RegView.e:
        return cpu.e;
      case RegView.h:
        return cpu.h;
      case RegView.l:
        return cpu.l;
      case RegView.sp:
        return cpu.sp;
      case RegView.pc:
        return cpu.pc;
      case RegView.flags:
        return cpu.fl();
    }
  }

  void setRegVal(RegView r, int v) {
    switch (r) {
      case RegView.a:
        cpu.a = v & 0xFF;
        break;
      case RegView.b:
        cpu.b = v & 0xFF;
        break;
      case RegView.c:
        cpu.c = v & 0xFF;
        break;
      case RegView.d:
        cpu.d = v & 0xFF;
        break;
      case RegView.e:
        cpu.e = v & 0xFF;
        break;
      case RegView.h:
        cpu.h = v & 0xFF;
        break;
      case RegView.l:
        cpu.l = v & 0xFF;
        break;
      case RegView.sp:
        cpu.sp = v & 0xFFFF;
        break;
      case RegView.pc:
        cpu.pc = v & 0xFFFF;
        break;
      case RegView.flags:
        cpu.sf(v);
        break;
    }
  }

  // ── setState helper ───────────────────────────────────────────────────────
  void _s(String st,
      {KitState? ks,
      bool? aOn,
      bool? dOn,
      bool? exec,
      bool? sh,
      bool resetDigits = true}) {
    status = st;
    if (ks != null) kstate = ks;
    if (aOn != null) addrOn = aOn;
    if (dOn != null) dataOn = dOn;
    if (exec != null) execDone = exec;
    if (sh != null) shifted = sh;
    if (resetDigits) inputDigits = 0;
    invalidateDisasm();
  }

  void _cancelFlows() {
    _fillStep = 0;
    _bmStep = 0;
    _mcStep = 0;
    _strStep = 0;
  }

  void _hMedium() {}

  void _hHeavy() {}

  // ── key handlers ──────────────────────────────────────────────────────────
  void onHex(int nibble) => setState(() {
        if (_inFlow) return;
        if (kstate == KitState.exmem || kstate == KitState.go) {
          if (!addrOn) return;
          if (inputDigits >= 4) {
            _hHeavy();
            status = 'ERR:ADDR';
            return;
          }
          addrBuf = ((addrBuf << 4) | nibble) & 0xFFFF;
          inputDigits++;
          invalidateDisasm();
        } else if (kstate == KitState.idle) {
          if (!dataOn || inputDigits >= 2) return;
          dataBuf = ((dataBuf << 4) | nibble) & 0xFF;
          inputDigits++;
        } else if (kstate == KitState.exreg) {
          final maxD = regView.is16 ? 4 : 2;
          if (inputDigits >= maxD) return;
          final nv = ((getRegVal(regView) << 4) | nibble) &
              (regView.is16 ? 0xFFFF : 0xFF);
          setRegVal(regView, nv);
          inputDigits++;
          dataBuf = getRegVal(regView);
        }
      });

  void onDel() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL', ks: KitState.idle, aOn: false, dOn: false);
          return;
        }
        if (inputDigits == 0) return;
        inputDigits--;
        if (kstate == KitState.exmem || kstate == KitState.go) {
          addrBuf = (addrBuf >> 4) & 0xFFFF;
          invalidateDisasm();
        } else {
          dataBuf = (dataBuf >> 4) & 0xFF;
        }
      });

  void onReset() {
    cpu.reset();
    addrBuf = 0;
    dataBuf = 0;
    _cancelFlows();
    _memActive = false;
    setState(() => _s('RESET',
        ks: KitState.idle, aOn: false, dOn: false, exec: false, sh: false));
  }

  void onShift() => setState(() {
        shifted = !shifted;
        status = shifted ? 'SHIFT' : 'READY';
      });

  void onSI() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (!addrOn) {
          _hHeavy();
          status = 'ERR:ADDR';
          return;
        }
        cpu.pc = addrBuf;
        cpu.halted = false;
        final cont = cpu.step();
        addrBuf = cpu.pc;
        dataBuf = cpu.mem[addrBuf];
        _s(cont ? 'STEP' : 'HALT',
            ks: KitState.idle, aOn: true, dOn: true, exec: false);
      });

  void onExReg() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        _s('REG:${regView.label}',
            ks: KitState.exreg, aOn: true, dOn: true, exec: false);
        _syncReg();
      });

  void _syncReg() {
    addrBuf = RegView.values.indexOf(regView);
    dataBuf = getRegVal(regView) & (regView.is16 ? 0xFFFF : 0xFF);
  }

  void onInsData() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (!_memActive) {
          _hHeavy();
          status = 'ERR:EXMEM';
          return;
        }
        if (kstate != KitState.idle) {
          dataBuf = cpu.mem[addrBuf];
          _s('INS', ks: KitState.idle, dOn: true);
        } else {
          cpu.mem[addrBuf] = dataBuf;
          addrBuf = (addrBuf + 1) & 0xFFFF;
          dataBuf = cpu.mem[addrBuf];
          _s('INS', dOn: true);
          _hMedium();
        }
      });

  void onVct() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (!addrOn) {
          _hHeavy();
          status = 'ERR:ADDR';
          return;
        }
        _vctAddr = addrBuf;
        status = 'VCT:SET';
        inputDigits = 0;
      });

  void onInt() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (!cpu.inte) {
          status = 'INT:DIS';
          return;
        }
        cpu.pc = _vctAddr;
        cpu.halted = false;
        final cont = cpu.step();
        addrBuf = cpu.pc;
        dataBuf = cpu.mem[addrBuf];
        _s(cont ? 'INT:OK' : 'INT:HLT', aOn: true, dOn: true);
      });

  void onGo() => setState(() {
        _cancelFlows();
        addrBuf = 0;
        _s('GO>', ks: KitState.go, aOn: true, dOn: false, exec: false);
      });

  void onDot() {
    if (kstate != KitState.go) {
      setState(() {
        _hHeavy();
        status = 'ERR:GO';
      });
      return;
    }
    setState(() {
      cpu.pc = addrBuf;
      cpu.halted = false;
      cpu.run();
      _s('${cpu.halted ? 'HALT' : 'DONE'} (${cpu.lastRunSteps})',
          ks: KitState.idle, aOn: false, dOn: false, exec: true);
      _hMedium();
    });
  }

  void onExmem() => setState(() {
        _cancelFlows();
        _memActive = false;
        addrBuf = 0;
        _s('ADDR>', ks: KitState.exmem, aOn: true, dOn: false, exec: false);
      });

  void onRel() => setState(() {
        _cancelFlows();
        addrBuf = 0;
        _s('RELOCATE', ks: KitState.idle, aOn: true, dOn: false, exec: false);
      });

  void onNext() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (kstate == KitState.exreg) {
          _nextReg();
          return;
        }
        if (kstate == KitState.exmem) {
          dataBuf = cpu.mem[addrBuf];
          _memActive = true;
          _s('DATA>', ks: KitState.idle, aOn: true, dOn: true, exec: false);
        } else if (_memActive) {
          cpu.mem[addrBuf] = dataBuf;
          addrBuf = (addrBuf + 1) & 0xFFFF;
          dataBuf = cpu.mem[addrBuf];
          _s('NEXT', aOn: true, dOn: true);
          _hMedium();
        } else {
          _hHeavy();
          status = 'ERR:EXMEM';
        }
      });

  void onPre() => setState(() {
        if (_inFlow) {
          _cancelFlows();
          _s('CANCEL');
          return;
        }
        if (kstate == KitState.exreg) {
          _preReg();
          return;
        }
        if (!_memActive) {
          _hHeavy();
          status = 'ERR:EXMEM';
          return;
        }
        cpu.mem[addrBuf] = dataBuf;
        addrBuf = (addrBuf - 1) & 0xFFFF;
        dataBuf = cpu.mem[addrBuf];
        _s('PRE', aOn: true, dOn: true, exec: false);
      });

  void _nextReg() {
    final i = RegView.values.indexOf(regView);
    regView = RegView.values[(i + 1) % RegView.values.length];
    inputDigits = 0;
    _syncReg();
    status = 'REG:${regView.label}';
    _hMedium();
  }

  void _preReg() {
    final i = RegView.values.indexOf(regView);
    regView =
        RegView.values[(i - 1 + RegView.values.length) % RegView.values.length];
    inputDigits = 0;
    _syncReg();
    status = 'REG:${regView.label}';
    _hMedium();
  }

  void jumpToAddr(int addr) => setState(() {
        _cancelFlows();
        addrBuf = addr;
        dataBuf = cpu.mem[addr];
        _s('JMP', ks: KitState.idle, aOn: true, dOn: true, exec: false);
      });

  void copyDisplay() {
    final addrStr = addrBuf.toRadixString(16).toUpperCase().padLeft(4, '0');
    final dataStr = dataBuf.toRadixString(16).toUpperCase().padLeft(2, '0');
    Clipboard.setData(ClipboardData(text: '$addrStr $dataStr'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to clipboard',
          style: TextStyle(fontFamily: kMono, fontSize: 12)),
      duration: Duration(seconds: 1),
      backgroundColor: kSurface2,
    ));
  }

  // ── FILL ──────────────────────────────────────────────────────────────────
  void onFill() {
    if (_bmStep > 0 || _mcStep > 0 || _strStep > 0) _cancelFlows();
    if (_fillStep == 0) {
      setState(() {
        _fillStart = addrBuf;
        _fillStep = 1;
        addrBuf = 0;
        inputDigits = 0;
        addrOn = true;
        dataOn = false;
        status = 'FILL:END';
      });
    } else if (_fillStep == 1) {
      setState(() {
        _fillStep = 2;
        inputDigits = 0;
        addrOn = false;
        dataOn = true;
        dataBuf = 0;
        status = 'FILL:VAL';
      });
    } else {
      setState(() {
        final end = addrBuf;
        final val = dataBuf;
        final from = _fillStart <= end ? _fillStart : end;
        final to = _fillStart <= end ? end : _fillStart;
        for (int i = from; i <= to; i++) {
          cpu.mem[i & 0xFFFF] = val;
        }
        _fillStep = 0;
        addrBuf = from;
        dataBuf = val;
        _s('FILL:OK', aOn: true, dOn: true);
        _hMedium();
      });
    }
  }

  // ── BLOCK MOVE ────────────────────────────────────────────────────────────
  void onBM() {
    if (_fillStep > 0 || _mcStep > 0 || _strStep > 0) _cancelFlows();
    if (_bmStep == 0) {
      setState(() {
        _bmSrc = addrBuf;
        _bmStep = 1;
        addrBuf = 0;
        inputDigits = 0;
        addrOn = true;
        dataOn = false;
        status = 'BM:END';
      });
    } else if (_bmStep == 1) {
      setState(() {
        _bmEnd = addrBuf;
        _bmStep = 2;
        addrBuf = 0;
        inputDigits = 0;
        addrOn = true;
        dataOn = false;
        status = 'BM:DST';
      });
    } else {
      setState(() {
        final dst = addrBuf;
        final len = (_bmEnd - _bmSrc).abs() + 1;
        for (int i = 0; i < len; i++) {
          cpu.mem[(dst + i) & 0xFFFF] = cpu.mem[(_bmSrc + i) & 0xFFFF];
        }
        _bmStep = 0;
        addrBuf = dst;
        dataBuf = cpu.mem[dst];
        _s('BM:OK', aOn: true, dOn: true);
        _hMedium();
      });
    }
  }

  // ── MEMORY COMPARE ────────────────────────────────────────────────────────
  void onMemc() {
    if (_fillStep > 0 || _bmStep > 0 || _strStep > 0) _cancelFlows();
    if (_mcStep == 0) {
      setState(() {
        _mcBlk1 = addrBuf;
        _mcStep = 1;
        addrBuf = 0;
        inputDigits = 0;
        addrOn = true;
        dataOn = false;
        status = 'MC:BLK2';
      });
    } else if (_mcStep == 1) {
      setState(() {
        _mcBlk2 = addrBuf;
        _mcStep = 2;
        addrBuf = 0;
        dataBuf = 0;
        inputDigits = 0;
        addrOn = true;
        dataOn = false;
        status = 'MC:LEN';
      });
    } else {
      setState(() {
        final len = addrBuf == 0 ? 1 : addrBuf;
        int mismatch = -1;
        for (int i = 0; i < len; i++) {
          if (cpu.mem[(_mcBlk1 + i) & 0xFFFF] !=
              cpu.mem[(_mcBlk2 + i) & 0xFFFF]) {
            mismatch = i;
            break;
          }
        }
        _mcStep = 0;
        if (mismatch == -1) {
          addrBuf = _mcBlk1;
          dataBuf = 0;
          _s('MC:SAME', aOn: true, dOn: false);
        } else {
          addrBuf = (_mcBlk1 + mismatch) & 0xFFFF;
          dataBuf = cpu.mem[addrBuf];
          _s('MC:DIFF', aOn: true, dOn: true);
        }
        _hMedium();
      });
    }
  }

  // ── STRING SEARCH ─────────────────────────────────────────────────────────
  void onString() {
    if (_fillStep > 0 || _bmStep > 0 || _mcStep > 0) _cancelFlows();
    if (_strStep == 0) {
      setState(() {
        _strStart = addrBuf;
        _strStep = 1;
        dataBuf = 0;
        inputDigits = 0;
        addrOn = false;
        dataOn = true;
        status = 'STR:VAL';
      });
    } else {
      setState(() {
        final val = dataBuf;
        int found = -1;
        for (int i = _strStart; i < 0x10000; i++) {
          if (cpu.mem[i] == val) {
            found = i;
            break;
          }
        }
        _strStep = 0;
        if (found == -1) {
          addrBuf = _strStart;
          dataBuf = val;
          _s('STR:NF', aOn: true, dOn: true);
        } else {
          addrBuf = found;
          dataBuf = cpu.mem[found];
          _s('STR:FND', aOn: true, dOn: true);
        }
        _hMedium();
      });
    }
  }

  // ── assembler ─────────────────────────────────────────────────────────────
  int parseAsmOrigin(String source) {
    int origin = 0x2000;
    for (final line in source.split('\n')) {
      final t = line.trim().toUpperCase();
      if (t.startsWith('ORG')) {
        final p = t.split(RegExp(r'\s+'));
        if (p.length > 1) {
          origin = int.tryParse(p[1].replaceAll('H', ''), radix: 16) ?? 0x2000;
        }
        break;
      }
    }
    return origin;
  }

  List<String> asmSourceLines(String source) => source.split('\n').where((l) {
        final t = l.trim().toUpperCase();
        return !t.startsWith('ORG') && !t.startsWith(';') && t.isNotEmpty;
      }).toList();

  bool validateAsmSourceLineLimit({String? source}) {
    final src = source ?? asmCtrl.text;
    final lineCount = src.split('\n').length;
    if (lineCount > kAsmMaxSourceLines) {
      asmError =
          'Too many lines: $lineCount (max $kAsmMaxSourceLines). Reduce source length.';
      return false;
    }
    return true;
  }

  bool validateAsmMemoryBounds(List<AsmLine> lines, int origin) {
    if (origin < 0 || origin > 0xFFFF) {
      asmError = 'Invalid ORG: ${origin.toRadixString(16).toUpperCase()}H';
      return false;
    }

    int maxAddr = origin;
    for (final line in lines) {
      if (line.address == null || line.bytes.isEmpty) continue;
      final lineEnd = line.address! + line.bytes.length - 1;
      if (lineEnd > maxAddr) maxAddr = lineEnd;
    }

    if (maxAddr >= kMemorySize) {
      final neededBytes = maxAddr - 0xFFFF;
      asmError =
          'Program exceeds memory by $neededBytes byte(s). End address ${maxAddr.toRadixString(16).toUpperCase()}H > FFFFH.';
      return false;
    }
    return true;
  }

  void asmLoad() => setState(() {
        asmError = '';
        if (!validateAsmSourceLineLimit()) {
          status = 'ASM ERR';
          _hHeavy();
          return;
        }
        final origin = parseAsmOrigin(asmCtrl.text);
        asmOrigin = origin;
        final lines = asmSourceLines(asmCtrl.text);
        asmLines = asmEngine.assemble(lines, origin);
        final errs = asmLines.where((l) => l.error != null).toList();
        if (errs.isNotEmpty) {
          asmError = errs.map((l) => '${l.mnemonic}: ${l.error}').join(', ');
          _hHeavy();
          status = 'ASM ERR';
          return;
        }
        if (!validateAsmMemoryBounds(asmLines, origin)) {
          _hHeavy();
          status = 'ASM ERR';
          return;
        }
        for (final line in asmLines) {
          if (line.address != null && line.bytes.isNotEmpty) {
            for (int i = 0; i < line.bytes.length; i++) {
              cpu.mem[(line.address! + i) & 0xFFFF] = line.bytes[i];
            }
          }
        }
        addrBuf = origin;
        status = 'LOADED';
        invalidateDisasm();
      });

  void asmRun() {
    asmLoad();
    if (asmError.isEmpty) {
      setState(() {
        cpu.pc = asmOrigin;
        cpu.halted = false;
        cpu.run();
        status = '${cpu.halted ? 'HALT' : 'DONE'} (${cpu.lastRunSteps})';
      });
    }
  }

  void sendToKit(int origin) {
    setState(() {
      for (final line in asmLines) {
        if (line.address != null && line.bytes.isNotEmpty) {
          for (int i = 0; i < line.bytes.length; i++) {
            cpu.mem[(line.address! + i) & 0xFFFF] = line.bytes[i];
          }
        }
      }
      cpu.reset();
      addrBuf = origin;
      dataBuf = cpu.mem[origin];
      _s('LOADED',
          ks: KitState.idle, aOn: true, dOn: true, exec: false, sh: false);
      _memActive = true;
      asmMode = false;
    });
  }

  // ── sheets ────────────────────────────────────────────────────────────────
  void _sheet(Widget child) => showModalBottomSheet(
        context: context,
        useSafeArea: false,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: kSurface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        builder: (ctx) {
          final mq = MediaQuery.of(ctx);
          return SafeArea(
            top: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.only(
                bottom: mq.viewInsets.bottom,
              ),
              child: child,
            ),
          );
        },
      );

  void showAbout() => _sheet(const AboutSheet());
  void showManual() => _sheet(const ManualSheet());
  void showOpcodeTable() => _sheet(const OpcodeSheet());
  void showConverter() => _sheet(const ConverterSheet());
  void showNotices() => _sheet(const NoticesSheet());

  // ── disassembler ──────────────────────────────────────────────────────────
  static const Map<int, String> mn = {
    0x00: 'NOP',
    0x76: 'HLT',
    0xFB: 'EI',
    0xF3: 'DI',
    0x3E: 'MVI A',
    0x06: 'MVI B',
    0x0E: 'MVI C',
    0x16: 'MVI D',
    0x1E: 'MVI E',
    0x26: 'MVI H',
    0x2E: 'MVI L',
    0x36: 'MVI M',
    0x3A: 'LDA',
    0x32: 'STA',
    0x2A: 'LHLD',
    0x22: 'SHLD',
    0x01: 'LXI B',
    0x11: 'LXI D',
    0x21: 'LXI H',
    0x31: 'LXI SP',
    0x0A: 'LDAX B',
    0x1A: 'LDAX D',
    0x02: 'STAX B',
    0x12: 'STAX D',
    0xC6: 'ADI',
    0xD6: 'SUI',
    0xE6: 'ANI',
    0xF6: 'ORI',
    0xFE: 'CPI',
    0xEE: 'XRI',
    0xCE: 'ACI',
    0xDE: 'SBI',
    0xEB: 'XCHG',
    0xF9: 'SPHL',
    0xE9: 'PCHL',
    0xE3: 'XTHL',
    0xC3: 'JMP',
    0xC2: 'JNZ',
    0xCA: 'JZ',
    0xD2: 'JNC',
    0xDA: 'JC',
    0xF2: 'JP',
    0xFA: 'JM',
    0xE2: 'JPO',
    0xEA: 'JPE',
    0xCD: 'CALL',
    0xC4: 'CNZ',
    0xCC: 'CZ',
    0xD4: 'CNC',
    0xDC: 'CC',
    0xF4: 'CP',
    0xFC: 'CM',
    0xC9: 'RET',
    0xC0: 'RNZ',
    0xC8: 'RZ',
    0xD0: 'RNC',
    0xD8: 'RC',
    0xF0: 'RP',
    0xF8: 'RM',
    0xC5: 'PUSH B',
    0xD5: 'PUSH D',
    0xE5: 'PUSH H',
    0xF5: 'PUSH PSW',
    0xC1: 'POP B',
    0xD1: 'POP D',
    0xE1: 'POP H',
    0xF1: 'POP PSW',
    0x07: 'RLC',
    0x0F: 'RRC',
    0x17: 'RAL',
    0x1F: 'RAR',
    0x2F: 'CMA',
    0x3F: 'CMC',
    0x37: 'STC',
    0x27: 'DAA',
    0x20: 'RIM',
    0x30: 'SIM',
    0xDB: 'IN',
    0xD3: 'OUT',
  };
  static const Set<int> tw = {
    0x3E,
    0x06,
    0x0E,
    0x16,
    0x1E,
    0x26,
    0x2E,
    0x36,
    0xC6,
    0xD6,
    0xE6,
    0xF6,
    0xFE,
    0xEE,
    0xCE,
    0xDE,
    0xDB,
    0xD3
  };
  static const Set<int> th = {
    0x3A,
    0x32,
    0x2A,
    0x22,
    0x01,
    0x11,
    0x21,
    0x31,
    0xC3,
    0xC2,
    0xCA,
    0xD2,
    0xDA,
    0xF2,
    0xFA,
    0xE2,
    0xEA,
    0xCD,
    0xC4,
    0xCC,
    0xD4,
    0xDC,
    0xF4,
    0xFC
  };
  static const List<String> rn = ['B', 'C', 'D', 'E', 'H', 'L', 'M', 'A'];

  String disasmOp(int op) {
    if (op >= 0x40 && op <= 0x7F && op != 0x76) {
      return 'MOV ${rn[(op >> 3) & 7]},${rn[op & 7]}';
    }
    if (op >= 0x80 && op <= 0xBF) {
      const ops = ['ADD', 'ADC', 'SUB', 'SBB', 'ANA', 'XRA', 'ORA', 'CMP'];
      return '${ops[(op >> 3) & 7]} ${rn[op & 7]}';
    }
    if ((op & 7) == 4 && op >= 4 && op <= 0x3C) {
      return 'INR ${rn[(op >> 3) & 7]}';
    }
    if ((op & 7) == 5 && op >= 5 && op <= 0x3D) {
      return 'DCR ${rn[(op >> 3) & 7]}';
    }
    const inx = {0x03: 'INX B', 0x13: 'INX D', 0x23: 'INX H', 0x33: 'INX SP'};
    if (inx.containsKey(op)) return inx[op]!;
    const dcx = {0x0B: 'DCX B', 0x1B: 'DCX D', 0x2B: 'DCX H', 0x3B: 'DCX SP'};
    if (dcx.containsKey(op)) return dcx[op]!;
    const dad = {0x09: 'DAD B', 0x19: 'DAD D', 0x29: 'DAD H', 0x39: 'DAD SP'};
    if (dad.containsKey(op)) return dad[op]!;
    if ((op & 0xC7) == 0xC7) return 'RST ${(op >> 3) & 7}';
    return mn[op] ?? '';
  }

  List<Map<String, dynamic>> _disasm(int anchor, int before, int after) {
    final scanStart = (anchor - 60).clamp(0, 0xFFFF);
    final addrs = <int>[];
    int a = scanStart;
    while (a <= anchor) {
      addrs.add(a);
      final op = cpu.mem[a];
      a += th.contains(op)
          ? 3
          : tw.contains(op)
              ? 2
              : 1;
    }
    final ba = <int>[];
    for (int i = addrs.length - 1; i >= 0 && ba.length < before; i--) {
      ba.insert(0, addrs[i]);
    }
    final from = ba.isNotEmpty ? ba.first : anchor;
    final out = <Map<String, dynamic>>[];
    int cur = from;
    while (out.length < before + 1 + after && cur < 0x10000) {
      final op = cpu.mem[cur];
      final raw = disasmOp(op);
      String line;
      int sz = 1;
      if (th.contains(op)) {
        final lo = cpu.mem[(cur + 1) & 0xFFFF],
            hi = cpu.mem[(cur + 2) & 0xFFFF];
        line =
            '${raw.isEmpty ? '???' : raw}  ${((hi << 8) | lo).toRadixString(16).toUpperCase().padLeft(4, '0')}H';
        sz = 3;
      } else if (tw.contains(op)) {
        line =
            '${raw.isEmpty ? '???' : raw}  ${cpu.mem[(cur + 1) & 0xFFFF].toRadixString(16).toUpperCase().padLeft(2, '0')}H';
        sz = 2;
      } else if (raw.isEmpty) {
        line = '${op.toRadixString(16).toUpperCase().padLeft(2, '0')}H (DATA)';
      } else {
        line = raw;
      }
      out.add({'addr': cur, 'line': line});
      cur += sz;
    }
    return out;
  }

  // ── build ─────────────────────────────────────────────────────────────────
  Widget _mi(IconData icon, String label, Color color) => Row(children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 10),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kText, fontWeight: FontWeight.w600)),
      ]);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kSurface,
        titleSpacing: 14,
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'KIT',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: kText,
                    fontFamily: kMono,
                  ),
            ),
            TextSpan(
              text: '85',
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                    color: kGreen,
                    fontFamily: kMono,
                  ),
            ),
          ]),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilledButton.tonal(
              onPressed: () => setState(() => asmMode = !asmMode),
              style: FilledButton.styleFrom(
                backgroundColor: asmMode
                    ? kGreen.withValues(alpha: 0.2)
                    : kBlue.withValues(alpha: 0.22),
                foregroundColor: asmMode ? kGreen : kBlueBright,
                minimumSize: const Size(72, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: asmMode
                          ? kGreen.withValues(alpha: 0.45)
                          : kBlueBright.withValues(alpha: 0.35)),
                ),
              ),
              child: Text(
                asmMode ? 'KIT' : 'ASM',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  fontFamily: kMono,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: kTextDim),
            color: kSurface2,
            onSelected: (v) {
              if (v == 'manual') {
                showManual();
              } else if (v == 'opcodes') {
                showOpcodeTable();
              } else if (v == 'converter') {
                showConverter();
              } else if (v == 'notices') {
                showNotices();
              } else if (v == 'about') {
                showAbout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'manual',
                  child: _mi(Icons.menu_book, 'User Manual', kBlueBright)),
              PopupMenuItem(
                  value: 'opcodes',
                  child: _mi(Icons.table_chart, 'Opcode Table', kGreen)),
              PopupMenuItem(
                  value: 'converter',
                  child: _mi(Icons.calculate, 'Number Converter', kOrange)),
              PopupMenuItem(
                  value: 'notices',
                  child: _mi(Icons.warning_amber_rounded, 'Notices & Warnings',
                      kOrange)),
              const PopupMenuDivider(),
              PopupMenuItem(
                  value: 'about',
                  child: _mi(Icons.info_outline, 'About', kTextDim)),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: asmMode
            ? AsmView(state: this, isLandscape: isLandscape)
            : _buildKitView(isLandscape),
      ),
    );
  }

  // ── kit view ──────────────────────────────────────────────────────────────
  Widget _buildKitView(bool isLandscape) {
    if (isLandscape) {
      return Row(children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: DisasmPanel(state: this)),
        Expanded(
            child: Column(children: [
          HexDisplay(state: this),
          KitStatusBar(state: this),
          Container(height: 1, color: kBorder),
          Expanded(child: KitKeyboard(state: this)),
        ])),
      ]);
    }
    return Column(children: [
      if (disasmVisible) DisasmPanel(state: this),
      DisasmToggle(state: this),
      DecStrip(state: this),
      HexDisplay(state: this),
      KitStatusBar(state: this),
      Container(height: 1, color: kBorder),
      Expanded(child: KitKeyboard(state: this)),
    ]);
  }
}
