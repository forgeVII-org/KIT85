import "package:kit85/cpu/cpu_8085.dart";
import "package:kit85/cpu/assembler_8085.dart";
import "package:kit85/cpu/sample_programs.dart";

void main() {
  final cpu = CPU8085();
  final asm = Assembler8085();

  // Load 16-bit subtract sample
  final prog = samplePrograms.firstWhere((p) => p.name == "Subtract Two 16-bit Numbers");
  final lines = asm.assemble(prog.code.split("\n"), 0x2500);
  for (final line in lines) {
    if (line.address != null && line.bytes.isNotEmpty) {
      for (int i = 0; i < line.bytes.length; i++) {
        cpu.mem[(line.address! + i) & 0xFFFF] = line.bytes[i];
      }
    }
  }

  // Test: 0005 - 0008 (first=0005, second=0008)
  cpu.mem[0x2800] = 0x05;  // LSB of 0005
  cpu.mem[0x2801] = 0x00;  // MSB of 0005
  cpu.mem[0x2802] = 0x08;  // LSB of 0008
  cpu.mem[0x2803] = 0x00;  // MSB of 0008

  cpu.pc = 0x2500;
  cpu.halted = false;
  cpu.run();

  print("First (2800-2801): ${cpu.mem[0x2800].toRadixString(16).padLeft(2, "0")} ${cpu.mem[0x2801].toRadixString(16).padLeft(2, "0")}");
  print("Second (2802-2803): ${cpu.mem[0x2802].toRadixString(16).padLeft(2, "0")} ${cpu.mem[0x2803].toRadixString(16).padLeft(2, "0")}");
  print("Result (2804-2805): ${cpu.mem[0x2804].toRadixString(16).padLeft(2, "0")} ${cpu.mem[0x2805].toRadixString(16).padLeft(2, "0")}");
  print("Borrow (2806): ${cpu.mem[0x2806].toRadixString(16).padLeft(2, "0")}");
}
