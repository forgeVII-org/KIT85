import 'package:flutter_test/flutter_test.dart';
import 'package:kit85/cpu/assembler_8085.dart';

void main() {
  group('Assembler8085 numeric parsing', () {
    final asm = Assembler8085();

    List<int> encode(String source) {
      final lines = asm.assemble([source], 0x8000);
      return lines.first.bytes;
    }

    test('uses hex by default for bare 16-bit address', () {
      expect(encode('STA 2000'), equals([0x32, 0x00, 0x20]));
      expect(encode('LDA 2AF0'), equals([0x3A, 0xF0, 0x2A]));
      expect(encode('JMP 1234'), equals([0xC3, 0x34, 0x12]));
    });

    test('supports explicit decimal with D suffix', () {
      expect(encode('STA 2000D'), equals([0x32, 0xD0, 0x07]));
      expect(encode('MVI A, 10D'), equals([0x3E, 0x0A]));
    });

    test('supports explicit binary with B suffix', () {
      expect(encode('MVI B, 10101010B'), equals([0x06, 0xAA]));
    });

    test('keeps existing hex forms working', () {
      expect(encode('MVI A, 05H'), equals([0x3E, 0x05]));
      expect(encode('MVI A, 0x1F'), equals([0x3E, 0x1F]));
      expect(encode('MVI A, 10'), equals([0x3E, 0x10]));
    });
  });

  group('Assembler8085 label encoding', () {
    final asm = Assembler8085();

    test('resolves labels in 16-bit instructions', () {
      final lines = asm.assemble(
        [
          'START: NOP',
          'JMP START',
        ],
        0x9000,
      );

      expect(lines[0].bytes, equals([0x00]));
      expect(lines[1].bytes, equals([0xC3, 0x00, 0x90]));
    });
  });
}
