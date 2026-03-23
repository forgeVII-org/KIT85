class SampleProgram {
  final String name;
  final String description;
  final String code;

  const SampleProgram({
    required this.name,
    required this.description,
    required this.code,
  });
}

const samplePrograms = <SampleProgram>[
  SampleProgram(
    name: 'Counter (0-255)',
    description: 'Counts from 0 to 255 in register A',
    code: '''; Count upward in A until it overflows back to 00H
ORG 2000H

MVI A, 00H
COUNT_LOOP: INR A
JNZ COUNT_LOOP
HLT
''',
  ),
  SampleProgram(
    name: 'Add Two Numbers',
    description: 'Adds B and C registers, stores result in A',
    code: '''; Add two values using registers B and C
ORG 2000H

MVI B, 14H
MVI C, 28H
MOV A, B
ADD C
STA 2100H
HLT
''',
  ),
  SampleProgram(
    name: 'Factorial (5!)',
    description: 'Calculate factorial of 5',
    code: '''; Compute 5! and store the result at 2100H
ORG 2000H

MVI B, 05H      ; B = n
MVI A, 01H      ; A = running result
FACT_LOOP: MOV C, B
CALL MUL_A_BY_C ; A = A * B
DCR B
MOV E, A
MOV A, B
CPI 01H
MOV A, E
JNZ FACT_LOOP
STA 2100H
HLT

MUL_A_BY_C: MOV D, A
MVI A, 00H
MUL_LOOP: ADD D
DCR C
JNZ MUL_LOOP
RET
''',
  ),
  SampleProgram(
    name: 'Clear Memory Block',
    description: 'Clears 16 bytes starting at 2100H',
    code: '''; Fill 2100H..210FH with 00H
ORG 2000H

LXI H, 2100H
MVI B, 10H
CLEAR_LOOP: MVI M, 00H
INX H
DCR B
JNZ CLEAR_LOOP
HLT
''',
  ),
  SampleProgram(
    name: 'Rotate Register A',
    description: 'Rotates A register left 4 times',
    code: '''; Rotate A to the left four times
ORG 2000H

MVI A, 96H
MVI B, 04H
ROT_LOOP: RLC
DCR B
JNZ ROT_LOOP
HLT
''',
  ),
  SampleProgram(
    name: 'Compare and Jump',
    description: 'Compares A with B, jumps based on result',
    code: '''; Compare A and B and set C as relation code
; 01H = A>B, 02H = A<B, 03H = A==B
ORG 2000H

MVI A, 2AH
MVI B, 30H
CMP B
JC LESS_THAN
JZ EQUAL_TO
MVI C, 01H
JMP DONE
LESS_THAN: MVI C, 02H
JMP DONE
EQUAL_TO: MVI C, 03H
DONE: HLT
''',
  ),
  SampleProgram(
    name: 'Stack Operations',
    description: 'Demonstrates PUSH and POP',
    code: '''; Push BC onto stack, then pop into DE
ORG 2000H

LXI SP, 2400H
MVI B, 12H
MVI C, 34H
PUSH B
MVI B, 00H
MVI C, 00H
POP D
HLT
''',
  ),
  SampleProgram(
    name: 'Copy Memory Block',
    description: 'Copies 8 bytes from 2100H to 2110H',
    code: '''; Copy bytes from source block (HL) to destination (DE)
ORG 2000H

LXI H, 2100H
LXI D, 2110H
MVI B, 08H
COPY_LOOP: MOV A, M
STAX D
INX H
INX D
DCR B
JNZ COPY_LOOP
HLT
''',
  ),
  SampleProgram(
    name: 'Binary to BCD',
    description: 'Converts binary to BCD format',
    code: '''; Convert value in A to decimal digits by repeated subtraction
; Stores hundreds at 2200H, tens at 2201H, ones at 2202H
ORG 2000H

MVI A, 99H
MVI B, 00H
MVI C, 00H
HUND_LOOP: CPI 64H
JC TENS_LOOP
SUI 64H
INR B
JMP HUND_LOOP
TENS_LOOP: CPI 0AH
JC BCD_DONE
SUI 0AH
INR C
JMP TENS_LOOP
BCD_DONE: STA 2202H
MOV A, C
STA 2201H
MOV A, B
STA 2200H
HLT
''',
  ),
  SampleProgram(
    name: 'Call Subroutine',
    description: 'Demonstrates CALL and RET',
    code: '''; Call a subroutine that adds B into A
ORG 2000H

MVI A, 15H
MVI B, 27H
CALL ADD_SUB
STA 2300H
HLT

ADD_SUB: ADD B
RET
''',
  ),
];
