import 'package:flutter/material.dart';
import '../constants.dart';

class OpcodeSheet extends StatefulWidget {
  const OpcodeSheet({super.key});
  @override
  State<OpcodeSheet> createState() => _OpcodeSheetState();
}

class _OpcodeSheetState extends State<OpcodeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Widget _lbl(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        color: kSurface2,
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: kText,
                fontSize: 10,
                fontFamily: kMono,
                fontWeight: FontWeight.bold)),
      );

  Widget _cell(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        color: kSurface,
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: kGreen, fontSize: 10, fontFamily: kMono)),
      );

  Widget _table(List<List<String>> rows) => Table(
        border: TableBorder.all(color: kBorder, width: 0.5),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: rows
            .asMap()
            .entries
            .map((re) => TableRow(
                  children: re.value
                      .asMap()
                      .entries
                      .map((ce) => Padding(
                            padding: const EdgeInsets.all(1),
                            child: ce.value == '--' || ce.value == ''
                                ? Container(
                                    color: kBg,
                                    padding: const EdgeInsets.all(5))
                                : (re.key == 0 || ce.key == 0)
                                    ? _lbl(ce.value)
                                    : _cell(ce.value),
                          ))
                      .toList(),
                ))
            .toList(),
      );

  Widget _sec(String t, Color c) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: c.withValues(alpha: 0.4))),
        child: Text(t,
            style: TextStyle(
                color: c,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontFamily: kMono)),
      );

  Widget _listHeader() => Container(
        color: kSurface2,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(children: const [
          Expanded(
              flex: 4,
              child: Text('MNEMONIC',
                  style: TextStyle(
                      color: kText,
                      fontSize: 10,
                      fontFamily: kMono,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
          Expanded(
              flex: 2,
              child: Text('OPCODE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: kText,
                      fontSize: 10,
                      fontFamily: kMono,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
          Expanded(
              flex: 1,
              child: Text('BYTES',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: kText,
                      fontSize: 10,
                      fontFamily: kMono,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1))),
        ]),
      );

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, sc) => SafeArea(
          child: Column(children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(2))),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(children: [
                  const Icon(Icons.table_chart, color: kGreen, size: 16),
                  const SizedBox(width: 8),
                  const Text('Opcode Table',
                      style: TextStyle(
                          color: kText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                ])),
            TabBar(
                controller: _tab,
                indicatorColor: kGreen,
                labelColor: kGreen,
                unselectedLabelColor: kTextDim,
                tabs: const [Tab(text: 'LIST'), Tab(text: 'GRID')]),
            Container(
                width: double.infinity,
                color: kSurface2,
                padding: const EdgeInsets.fromLTRB(12, 5, 12, 6),
                child: const Text(
                    'Reference includes 8085 mnemonic/opcode mapping. LIST = categorized quick scan. GRID = compact opcode matrices. Search/filter is not available in this build.',
                    style: TextStyle(
                        color: kTextDim, fontSize: 10, height: 1.35))),
            Expanded(
                child: TabBarView(
                    controller: _tab, children: [_list(sc), _grid()])),
          ]),
        ),
      );

  Widget _list(ScrollController sc) {
    final sections = [
      {
        't': 'DATA TRANSFER',
        'c': kBlueBright,
        'ops': [
          ['MOV r1,r2', '40-7F', '1'],
          ['MVI r,d8', '06+', '2'],
          ['LXI rp,d16', '01+', '3'],
          ['LDA addr', '3A', '3'],
          ['STA addr', '32', '3'],
          ['LHLD addr', '2A', '3'],
          ['SHLD addr', '22', '3'],
          ['LDAX B/D', '0A/1A', '1'],
          ['STAX B/D', '02/12', '1'],
          ['XCHG', 'EB', '1']
        ]
      },
      {
        't': 'ARITHMETIC',
        'c': kGreen,
        'ops': [
          ['ADD r', '80-87', '1'],
          ['ADC r', '88-8F', '1'],
          ['SUB r', '90-97', '1'],
          ['SBB r', '98-9F', '1'],
          ['ADI d8', 'C6', '2'],
          ['ACI d8', 'CE', '2'],
          ['SUI d8', 'D6', '2'],
          ['SBI d8', 'DE', '2'],
          ['INR r', '04+', '1'],
          ['DCR r', '05+', '1'],
          ['INX rp', '03+', '1'],
          ['DCX rp', '0B+', '1'],
          ['DAD rp', '09+', '1'],
          ['DAA', '27', '1']
        ]
      },
      {
        't': 'LOGICAL',
        'c': kOrange,
        'ops': [
          ['ANA r', 'A0-A7', '1'],
          ['ANI d8', 'E6', '2'],
          ['ORA r', 'B0-B7', '1'],
          ['ORI d8', 'F6', '2'],
          ['XRA r', 'A8-AF', '1'],
          ['XRI d8', 'EE', '2'],
          ['CMP r', 'B8-BF', '1'],
          ['CPI d8', 'FE', '2'],
          ['CMA', '2F', '1'],
          ['CMC', '3F', '1'],
          ['STC', '37', '1']
        ]
      },
      {
        't': 'ROTATE',
        'c': const Color(0xFFCE93D8),
        'ops': [
          ['RLC', '07', '1'],
          ['RRC', '0F', '1'],
          ['RAL', '17', '1'],
          ['RAR', '1F', '1']
        ]
      },
      {
        't': 'BRANCH',
        'c': kRed,
        'ops': [
          ['JMP addr', 'C3', '3'],
          ['JNZ', 'C2', '3'],
          ['JZ', 'CA', '3'],
          ['JNC', 'D2', '3'],
          ['JC', 'DA', '3'],
          ['JP', 'F2', '3'],
          ['JM', 'FA', '3'],
          ['JPO', 'E2', '3'],
          ['JPE', 'EA', '3'],
          ['CALL addr', 'CD', '3'],
          ['CNZ', 'C4', '3'],
          ['CZ', 'CC', '3'],
          ['CNC', 'D4', '3'],
          ['CC', 'DC', '3'],
          ['CP', 'F4', '3'],
          ['CM', 'FC', '3'],
          ['CPE', 'EC', '3'],
          ['CPO', 'E4', '3'],
          ['RET', 'C9', '1'],
          ['RNZ', 'C0', '1'],
          ['RZ', 'C8', '1'],
          ['RNC', 'D0', '1'],
          ['RC', 'D8', '1'],
          ['RP', 'F0', '1'],
          ['RM', 'F8', '1'],
          ['RPE', 'E8', '1'],
          ['RPO', 'E0', '1']
        ]
      },
      {
        't': 'STACK',
        'c': const Color(0xFF4DB6AC),
        'ops': [
          ['PUSH B', 'C5', '1'],
          ['PUSH D', 'D5', '1'],
          ['PUSH H', 'E5', '1'],
          ['PUSH PSW', 'F5', '1'],
          ['POP B', 'C1', '1'],
          ['POP D', 'D1', '1'],
          ['POP H', 'E1', '1'],
          ['POP PSW', 'F1', '1'],
          ['XTHL', 'E3', '1'],
          ['SPHL', 'F9', '1']
        ]
      },
      {
        't': 'CONTROL',
        'c': kTextDim,
        'ops': [
          ['NOP', '00', '1'],
          ['HLT', '76', '1'],
          ['EI', 'FB', '1'],
          ['DI', 'F3', '1'],
          ['RIM', '20', '1'],
          ['SIM', '30', '1'],
          ['RST n', 'C7..FF', '1'],
          ['IN port', 'DB', '2'],
          ['OUT port', 'D3', '2'],
          ['PCHL', 'E9', '1']
        ]
      },
    ];
    return Column(children: [
      _listHeader(),
      const Divider(color: kBorder, height: 1),
      Expanded(
          child: ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              children: [
            ...sections.map((sec) {
              final ops = sec['ops'] as List;
              final color = sec['c'] as Color;
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _sec(sec['t'] as String, color),
                    ...ops.map((op) {
                      final o = op as List<String>;
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(children: [
                            Expanded(
                                flex: 4,
                                child: Text(o[0],
                                    style: const TextStyle(
                                        color: kText,
                                        fontSize: 12,
                                        fontFamily: kMono))),
                            Expanded(
                                flex: 2,
                                child: Text(o[1],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontFamily: kMono,
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text(o[2],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: kTextDim,
                                        fontSize: 12,
                                        fontFamily: kMono))),
                          ]));
                    }),
                  ]);
            }),
          ])),
    ]);
  }

  Widget _grid() => SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sec('REGISTER PAIR OPS', kBlueBright),
        const SizedBox(height: 4),
        _table([
          ['', 'B', 'D', 'H', 'SP'],
          ['LXI', '01', '11', '21', '31'],
          ['INX', '03', '13', '23', '33'],
          ['DCX', '0B', '1B', '2B', '3B'],
          ['DAD', '09', '19', '29', '39']
        ]),
        const SizedBox(height: 4),
        _table([
          ['', 'B', 'D', 'H', 'PSW'],
          ['PUSH', 'C5', 'D5', 'E5', 'F5'],
          ['POP', 'C1', 'D1', 'E1', 'F1']
        ]),
        const SizedBox(height: 4),
        _table([
          ['', 'B', 'D'],
          ['LDAX', '0A', '1A'],
          ['STAX', '02', '12']
        ]),
        const SizedBox(height: 12),
        _sec('BRANCH', kRed),
        const SizedBox(height: 4),
        _table([
          ['', 'C', 'NC', 'Z', 'NZ'],
          ['JMP', 'DA', 'D2', 'CA', 'C2'],
          ['CALL', 'DC', 'D4', 'CC', 'C4'],
          ['RET', 'D8', 'D0', 'C8', 'C0']
        ]),
        const SizedBox(height: 4),
        _table([
          ['', 'P', 'M', 'PE', 'PO'],
          ['JMP', 'F2', 'FA', 'EA', 'E2'],
          ['CALL', 'F4', 'FC', 'EC', 'E4'],
          ['RET', 'F0', 'F8', 'E8', 'E0']
        ]),
        const SizedBox(height: 4),
        Row(children: [
          _cell('JMP=C3'),
          const SizedBox(width: 4),
          _cell('CALL=CD'),
          const SizedBox(width: 4),
          _cell('RET=C9')
        ]),
        const SizedBox(height: 12),
        _sec('MOV  (dst \\ src)', const Color(0xFF4DB6AC)),
        const SizedBox(height: 4),
        _table([
          ['MOV', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'A'],
          ['B', '40', '41', '42', '43', '44', '45', '46', '47'],
          ['C', '48', '49', '4A', '4B', '4C', '4D', '4E', '4F'],
          ['D', '50', '51', '52', '53', '54', '55', '56', '57'],
          ['E', '58', '59', '5A', '5B', '5C', '5D', '5E', '5F'],
          ['H', '60', '61', '62', '63', '64', '65', '66', '67'],
          ['L', '68', '69', '6A', '6B', '6C', '6D', '6E', '6F'],
          ['M', '70', '71', '72', '73', '74', '75', '--', '77'],
          ['A', '78', '79', '7A', '7B', '7C', '7D', '7E', '7F']
        ]),
        const SizedBox(height: 12),
        _sec('ALU  (op \\ reg)', kGreen),
        const SizedBox(height: 4),
        _table([
          ['', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'A'],
          ['ADD', '80', '81', '82', '83', '84', '85', '86', '87'],
          ['ADC', '88', '89', '8A', '8B', '8C', '8D', '8E', '8F'],
          ['SUB', '90', '91', '92', '93', '94', '95', '96', '97'],
          ['SBB', '98', '99', '9A', '9B', '9C', '9D', '9E', '9F'],
          ['ANA', 'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7'],
          ['XRA', 'A8', 'A9', 'AA', 'AB', 'AC', 'AD', 'AE', 'AF'],
          ['ORA', 'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7'],
          ['CMP', 'B8', 'B9', 'BA', 'BB', 'BC', 'BD', 'BE', 'BF']
        ]),
        const SizedBox(height: 12),
        _sec('INR / DCR / MVI', kOrange),
        const SizedBox(height: 4),
        _table([
          ['', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'A'],
          ['INR', '04', '0C', '14', '1C', '24', '2C', '34', '3C'],
          ['DCR', '05', '0D', '15', '1D', '25', '2D', '35', '3D'],
          ['MVI', '06', '0E', '16', '1E', '26', '2E', '36', '3E']
        ]),
        const SizedBox(height: 12),
        _sec('RST', const Color(0xFFCE93D8)),
        const SizedBox(height: 4),
        _table([
          ['', '0', '1', '2', '3', '4', '5', '6', '7'],
          ['RST', 'C7', 'CF', 'D7', 'DF', 'E7', 'EF', 'F7', 'FF']
        ]),
        const SizedBox(height: 12),
        _sec('IMMEDIATE / MISC', kTextDim),
        const SizedBox(height: 4),
        Wrap(spacing: 4, runSpacing: 4, children: [
          for (final e in [
            ['ADI', 'C6'],
            ['ACI', 'CE'],
            ['SUI', 'D6'],
            ['SBI', 'DE'],
            ['ANI', 'E6'],
            ['XRI', 'EE'],
            ['ORI', 'F6'],
            ['CPI', 'FE'],
            ['IN', 'DB'],
            ['OUT', 'D3'],
            ['EI', 'FB'],
            ['DI', 'F3'],
            ['NOP', '00'],
            ['HLT', '76'],
            ['RLC', '07'],
            ['RRC', '0F'],
            ['RAL', '17'],
            ['RAR', '1F'],
            ['CMA', '2F'],
            ['CMC', '3F'],
            ['STC', '37'],
            ['DAA', '27'],
            ['RIM', '20'],
            ['SIM', '30'],
            ['XCHG', 'EB'],
            ['XTHL', 'E3'],
            ['SPHL', 'F9'],
            ['PCHL', 'E9'],
            ['LDA', '3A'],
            ['STA', '32'],
            ['LHLD', '2A'],
            ['SHLD', '22']
          ])
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: kBorder)),
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: '${e[0]} ',
                      style: const TextStyle(
                          color: kTextDim, fontSize: 10, fontFamily: kMono)),
                  TextSpan(
                      text: e[1],
                      style: const TextStyle(
                          color: kGreen,
                          fontSize: 10,
                          fontFamily: kMono,
                          fontWeight: FontWeight.bold)),
                ])))
        ]),
        const SizedBox(height: 20),
      ]));
}
