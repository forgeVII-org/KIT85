class AsmLine {
  String raw;
  String? label, mnemonic, error;
  List<String> operands;
  int? address;
  List<int> bytes;
  AsmLine(
      {required this.raw,
      this.label,
      this.mnemonic,
      this.operands = const [],
      this.address,
      this.bytes = const [],
      this.error});
}

class Assembler8085 {
  static const Map<String, int> _regs = {
    'B': 0,
    'C': 1,
    'D': 2,
    'E': 3,
    'H': 4,
    'L': 5,
    'M': 6,
    'A': 7
  };

  List<AsmLine> assemble(List<String> lines, int origin) {
    final result = <AsmLine>[];
    final labels = <String, int>{};
    int addr = origin;
    for (final raw in lines) {
      final t = raw.trim();
      if (t.isEmpty || t.startsWith(';')) {
        result.add(AsmLine(raw: raw));
        continue;
      }
      final line = AsmLine(raw: raw);
      String rest = t;
      if (rest.contains(':')) {
        final idx = rest.indexOf(':');
        line.label = rest.substring(0, idx).trim().toUpperCase();
        rest = rest.substring(idx + 1).trim();
        labels[line.label!] = addr;
      }
      if (rest.isEmpty || rest.startsWith(';')) {
        result.add(line);
        continue;
      }
      final ci = rest.indexOf(';');
      if (ci >= 0) rest = rest.substring(0, ci).trim();
      final parts = rest.split(RegExp(r'[\s,]+'));
      if (parts.isEmpty) {
        result.add(line);
        continue;
      }
      line.mnemonic = parts[0].toUpperCase();
      line.operands = parts
          .sublist(1)
          .map((e) => e.toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
      line.address = addr;
      addr += _sz(line.mnemonic!);
      result.add(line);
    }
    for (final line in result) {
      if (line.mnemonic == null || line.address == null) continue;
      line.bytes = _enc(line.mnemonic!, line.operands, labels);
      if (line.bytes.isEmpty && line.error == null) line.error = 'Unknown';
    }
    return result;
  }

  int _sz(String mn) {
    const two = {
      'MVI',
      'ADI',
      'ACI',
      'SUI',
      'SBI',
      'ANI',
      'XRI',
      'ORI',
      'CPI',
      'IN',
      'OUT'
    };
    const three = {
      'LXI',
      'LDA',
      'STA',
      'LHLD',
      'SHLD',
      'JMP',
      'JNZ',
      'JZ',
      'JNC',
      'JC',
      'JP',
      'JM',
      'JPO',
      'JPE',
      'CALL',
      'CNZ',
      'CZ',
      'CNC',
      'CC',
      'CP',
      'CM'
    };
    if (three.contains(mn)) return 3;
    if (two.contains(mn)) return 2;
    return 1;
  }

  int _v(String s, Map<String, int> labels) {
    s = s.toUpperCase().replaceAll(' ', '');
    if (labels.containsKey(s)) return labels[s]!;
    if (s.endsWith('D')) {
      return int.tryParse(s.substring(0, s.length - 1), radix: 10) ?? 0;
    }
    if (s.endsWith('B')) {
      return int.tryParse(s.substring(0, s.length - 1), radix: 2) ?? 0;
    }
    if (s.endsWith('H')) {
      return int.tryParse(s.substring(0, s.length - 1), radix: 16) ?? 0;
    }
    if (s.startsWith('0X')) return int.tryParse(s.substring(2), radix: 16) ?? 0;
    // 8085-style default: bare numeric constants are treated as hexadecimal.
    if (RegExp(r'^[0-9A-F]+$').hasMatch(s)) {
      return int.tryParse(s, radix: 16) ?? 0;
    }
    return int.tryParse(s, radix: 10) ?? 0;
  }

  int _r(String s) => _regs[s] ?? 0;

  List<int> _enc(String mn, List<String> ops, Map<String, int> labels) {
    int v(String s) => _v(s, labels);
    switch (mn) {
      case 'NOP':
        return [0x00];
      case 'HLT':
        return [0x76];
      case 'RET':
        return [0xC9];
      case 'RNZ':
        return [0xC0];
      case 'RZ':
        return [0xC8];
      case 'RNC':
        return [0xD0];
      case 'RC':
        return [0xD8];
      case 'RP':
        return [0xF0];
      case 'RM':
        return [0xF8];
      case 'EI':
        return [0xFB];
      case 'DI':
        return [0xF3];
      case 'RLC':
        return [0x07];
      case 'RRC':
        return [0x0F];
      case 'RAL':
        return [0x17];
      case 'RAR':
        return [0x1F];
      case 'CMA':
        return [0x2F];
      case 'CMC':
        return [0x3F];
      case 'STC':
        return [0x37];
      case 'DAA':
        return [0x27];
      case 'XCHG':
        return [0xEB];
      case 'XTHL':
        return [0xE3];
      case 'SPHL':
        return [0xF9];
      case 'PCHL':
        return [0xE9];
      case 'MOV':
        if (ops.length < 2) return [];
        return [0x40 | (_r(ops[0]) << 3) | _r(ops[1])];
      case 'MVI':
        if (ops.length < 2) return [];
        return [0x06 | (_r(ops[0]) << 3), v(ops[1]) & 0xFF];
      case 'LXI':
        {
          if (ops.length < 2) return [];
          final val = v(ops[1]);
          final rp = ops[0];
          int op = rp == 'B'
              ? 0x01
              : rp == 'D'
                  ? 0x11
                  : rp == 'H'
                      ? 0x21
                      : 0x31;
          return [op, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'LDA':
        {
          final val = v(ops[0]);
          return [0x3A, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'STA':
        {
          final val = v(ops[0]);
          return [0x32, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'LHLD':
        {
          final val = v(ops[0]);
          return [0x2A, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'SHLD':
        {
          final val = v(ops[0]);
          return [0x22, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'LDAX':
        return ops[0] == 'B' ? [0x0A] : [0x1A];
      case 'STAX':
        return ops[0] == 'B' ? [0x02] : [0x12];
      case 'ADD':
        return [0x80 | _r(ops[0])];
      case 'ADC':
        return [0x88 | _r(ops[0])];
      case 'SUB':
        return [0x90 | _r(ops[0])];
      case 'SBB':
        return [0x98 | _r(ops[0])];
      case 'ANA':
        return [0xA0 | _r(ops[0])];
      case 'XRA':
        return [0xA8 | _r(ops[0])];
      case 'ORA':
        return [0xB0 | _r(ops[0])];
      case 'CMP':
        return [0xB8 | _r(ops[0])];
      case 'ADI':
        return [0xC6, v(ops[0]) & 0xFF];
      case 'ACI':
        return [0xCE, v(ops[0]) & 0xFF];
      case 'SUI':
        return [0xD6, v(ops[0]) & 0xFF];
      case 'SBI':
        return [0xDE, v(ops[0]) & 0xFF];
      case 'ANI':
        return [0xE6, v(ops[0]) & 0xFF];
      case 'XRI':
        return [0xEE, v(ops[0]) & 0xFF];
      case 'ORI':
        return [0xF6, v(ops[0]) & 0xFF];
      case 'CPI':
        return [0xFE, v(ops[0]) & 0xFF];
      case 'INR':
      case 'INC':
        return [0x04 | (_r(ops[0]) << 3)];
      case 'DCR':
      case 'DEC':
        return [0x05 | (_r(ops[0]) << 3)];
      case 'INX':
        {
          final rp = ops[0];
          return rp == 'B'
              ? [0x03]
              : rp == 'D'
                  ? [0x13]
                  : rp == 'H'
                      ? [0x23]
                      : [0x33];
        }
      case 'DCX':
        {
          final rp = ops[0];
          return rp == 'B'
              ? [0x0B]
              : rp == 'D'
                  ? [0x1B]
                  : rp == 'H'
                      ? [0x2B]
                      : [0x3B];
        }
      case 'DAD':
        {
          final rp = ops[0];
          return rp == 'B'
              ? [0x09]
              : rp == 'D'
                  ? [0x19]
                  : rp == 'H'
                      ? [0x29]
                      : [0x39];
        }
      case 'PUSH':
        {
          final rp = ops[0];
          return rp == 'B'
              ? [0xC5]
              : rp == 'D'
                  ? [0xD5]
                  : rp == 'H'
                      ? [0xE5]
                      : [0xF5];
        }
      case 'POP':
        {
          final rp = ops[0];
          return rp == 'B'
              ? [0xC1]
              : rp == 'D'
                  ? [0xD1]
                  : rp == 'H'
                      ? [0xE1]
                      : [0xF1];
        }
      case 'JMP':
        {
          final val = v(ops[0]);
          return [0xC3, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JNZ':
        {
          final val = v(ops[0]);
          return [0xC2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JZ':
        {
          final val = v(ops[0]);
          return [0xCA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JNC':
        {
          final val = v(ops[0]);
          return [0xD2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JC':
        {
          final val = v(ops[0]);
          return [0xDA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JP':
        {
          final val = v(ops[0]);
          return [0xF2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JM':
        {
          final val = v(ops[0]);
          return [0xFA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JPO':
        {
          final val = v(ops[0]);
          return [0xE2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JPE':
        {
          final val = v(ops[0]);
          return [0xEA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CALL':
        {
          final val = v(ops[0]);
          return [0xCD, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CNZ':
        {
          final val = v(ops[0]);
          return [0xC4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CZ':
        {
          final val = v(ops[0]);
          return [0xCC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CNC':
        {
          final val = v(ops[0]);
          return [0xD4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CC':
        {
          final val = v(ops[0]);
          return [0xDC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CP':
        {
          final val = v(ops[0]);
          return [0xF4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CM':
        {
          final val = v(ops[0]);
          return [0xFC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'RST':
        {
          final n = v(ops[0]) & 7;
          return [0xC7 | (n << 3)];
        }
      case 'IN':
        return [0xDB, v(ops[0]) & 0xFF];
      case 'OUT':
        return [0xD3, v(ops[0]) & 0xFF];
      case 'RIM':
        return [0x20];
      case 'SIM':
        return [0x30];
      default:
        return [];
    }
  }
}
