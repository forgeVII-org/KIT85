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
  static const Set<String> _regPairs = {'B', 'D', 'H', 'SP'};
  static const Set<String> _regPairsBd = {'B', 'D'};
  static const Set<String> _pushPopPairs = {'B', 'D', 'H', 'PSW'};

  String? _lastError;

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
      _lastError = null;
      line.bytes = _enc(line.mnemonic!, line.operands, labels);
      if (_lastError != null) {
        line.error = _lastError;
      } else if (line.bytes.isEmpty && line.error == null) {
        line.error = 'Unknown';
      }
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

  bool _isReg(String s) => _regs.containsKey(s);

  bool _isRegPair(String s) => _regPairs.contains(s);

  bool _isRegPairBd(String s) => _regPairsBd.contains(s);

  bool _isPushPopPair(String s) => _pushPopPairs.contains(s);

  int _r(String s) => _regs[s]!;

  List<int> _enc(String mn, List<String> ops, Map<String, int> labels) {
    List<int> fail(String message) {
      _lastError = message;
      return [];
    }

    bool expectCount(int n) {
      if (ops.length == n) return true;
      _lastError = n == 1 ? 'Expected 1 operand' : 'Expected $n operands';
      return false;
    }

    int? reg8(String s) {
      if (_isReg(s)) return _r(s);
      return null;
    }

    int v(String s) => _v(s, labels);
    switch (mn) {
      case 'NOP':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x00];
      case 'HLT':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x76];
      case 'RET':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xC9];
      case 'RNZ':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xC0];
      case 'RZ':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xC8];
      case 'RNC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xD0];
      case 'RC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xD8];
      case 'RP':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xF0];
      case 'RM':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xF8];
      case 'EI':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xFB];
      case 'DI':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xF3];
      case 'RLC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x07];
      case 'RRC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x0F];
      case 'RAL':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x17];
      case 'RAR':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x1F];
      case 'CMA':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x2F];
      case 'CMC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x3F];
      case 'STC':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x37];
      case 'DAA':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x27];
      case 'XCHG':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xEB];
      case 'XTHL':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xE3];
      case 'SPHL':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xF9];
      case 'PCHL':
        if (!expectCount(0)) return fail(_lastError!);
        return [0xE9];
      case 'MOV':
        if (!expectCount(2)) return fail(_lastError!);
        final d = reg8(ops[0]);
        final s = reg8(ops[1]);
        if (d == null || s == null) {
          return fail('MOV expects register operands');
        }
        return [0x40 | (d << 3) | s];
      case 'MVI':
        if (!expectCount(2)) return fail(_lastError!);
        final d = reg8(ops[0]);
        if (d == null) return fail('MVI destination must be register');
        return [0x06 | (d << 3), v(ops[1]) & 0xFF];
      case 'LXI':
        {
          if (!expectCount(2)) return fail(_lastError!);
          final val = v(ops[1]);
          final rp = ops[0];
          if (!_isRegPair(rp)) {
            return fail('LXI register pair must be B, D, H or SP');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0x3A, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'STA':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0x32, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'LHLD':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0x2A, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'SHLD':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0x22, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'LDAX':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isRegPairBd(ops[0])) {
          return fail('LDAX register pair must be B or D');
        }
        return ops[0] == 'B' ? [0x0A] : [0x1A];
      case 'STAX':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isRegPairBd(ops[0])) {
          return fail('STAX register pair must be B or D');
        }
        return ops[0] == 'B' ? [0x02] : [0x12];
      case 'ADD':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('ADD operand must be register');
        return [0x80 | _r(ops[0])];
      case 'ADC':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('ADC operand must be register');
        return [0x88 | _r(ops[0])];
      case 'SUB':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('SUB operand must be register');
        return [0x90 | _r(ops[0])];
      case 'SBB':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('SBB operand must be register');
        return [0x98 | _r(ops[0])];
      case 'ANA':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('ANA operand must be register');
        return [0xA0 | _r(ops[0])];
      case 'XRA':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('XRA operand must be register');
        return [0xA8 | _r(ops[0])];
      case 'ORA':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('ORA operand must be register');
        return [0xB0 | _r(ops[0])];
      case 'CMP':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('CMP operand must be register');
        return [0xB8 | _r(ops[0])];
      case 'ADI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xC6, v(ops[0]) & 0xFF];
      case 'ACI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xCE, v(ops[0]) & 0xFF];
      case 'SUI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xD6, v(ops[0]) & 0xFF];
      case 'SBI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xDE, v(ops[0]) & 0xFF];
      case 'ANI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xE6, v(ops[0]) & 0xFF];
      case 'XRI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xEE, v(ops[0]) & 0xFF];
      case 'ORI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xF6, v(ops[0]) & 0xFF];
      case 'CPI':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xFE, v(ops[0]) & 0xFF];
      case 'INR':
      case 'INC':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('$mn operand must be register');
        return [0x04 | (_r(ops[0]) << 3)];
      case 'DCR':
      case 'DEC':
        if (!expectCount(1)) return fail(_lastError!);
        if (!_isReg(ops[0])) return fail('$mn operand must be register');
        return [0x05 | (_r(ops[0]) << 3)];
      case 'INX':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final rp = ops[0];
          if (!_isRegPair(rp)) {
            return fail('INX register pair must be B, D, H or SP');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final rp = ops[0];
          if (!_isRegPair(rp)) {
            return fail('DCX register pair must be B, D, H or SP');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final rp = ops[0];
          if (!_isRegPair(rp)) {
            return fail('DAD register pair must be B, D, H or SP');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final rp = ops[0];
          if (!_isPushPopPair(rp)) {
            return fail('PUSH register pair must be B, D, H or PSW');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final rp = ops[0];
          if (!_isPushPopPair(rp)) {
            return fail('POP register pair must be B, D, H or PSW');
          }
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
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xC3, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JNZ':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xC2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JZ':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xCA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JNC':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xD2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JC':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xDA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JP':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xF2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JM':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xFA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JPO':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xE2, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'JPE':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xEA, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CALL':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xCD, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CNZ':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xC4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CZ':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xCC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CNC':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xD4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CC':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xDC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CP':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xF4, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'CM':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final val = v(ops[0]);
          return [0xFC, val & 0xFF, (val >> 8) & 0xFF];
        }
      case 'RST':
        {
          if (!expectCount(1)) return fail(_lastError!);
          final n = v(ops[0]) & 7;
          return [0xC7 | (n << 3)];
        }
      case 'IN':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xDB, v(ops[0]) & 0xFF];
      case 'OUT':
        if (!expectCount(1)) return fail(_lastError!);
        return [0xD3, v(ops[0]) & 0xFF];
      case 'RIM':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x20];
      case 'SIM':
        if (!expectCount(0)) return fail(_lastError!);
        return [0x30];
      default:
        return [];
    }
  }
}
