import 'package:flutter/material.dart';

import '../constants.dart';
import '../cpu/sample_programs.dart';

class _SampleProcedureInfo {
  final List<String> inputs;
  final List<String> outputs;
  final List<_AddrValue> exampleInput;
  final List<_AddrValue> exampleOutput;

  const _SampleProcedureInfo({
    required this.inputs,
    required this.outputs,
    required this.exampleInput,
    required this.exampleOutput,
  });
}

class _AddrValue {
  final String address;
  final String value;

  const _AddrValue(this.address, this.value);
}

const _sampleProcedureByName = <String, _SampleProcedureInfo>{
  'Add Two 8-bit Numbers': _SampleProcedureInfo(
    inputs: ['2300H = first value', '2301H = second value'],
    outputs: ['2302H = sum (low byte)', '2303H = carry (00/01)'],
    exampleInput: [
      _AddrValue('2300H', '03H'),
      _AddrValue('2301H', '04H'),
    ],
    exampleOutput: [
      _AddrValue('2302H', '07H'),
      _AddrValue('2303H', '00H'),
    ],
  ),
  'Subtract Two 8-bit Numbers': _SampleProcedureInfo(
    inputs: ['2300H = minuend', '2301H = subtrahend'],
    outputs: ['2302H = difference', '2303H = borrow flag (00/01)'],
    exampleInput: [
      _AddrValue('2300H', '09H'),
      _AddrValue('2301H', '05H'),
    ],
    exampleOutput: [
      _AddrValue('2302H', '04H'),
      _AddrValue('2303H', '00H'),
    ],
  ),
  'Add Two 16-bit Numbers': _SampleProcedureInfo(
    inputs: ['2800H..2801H = first 16-bit value', '2802H..2803H = second 16-bit value'],
    outputs: ['2804H..2805H = 16-bit sum', '2806H = carry (00/01)'],
    exampleInput: [
      _AddrValue('2800H..2801H', '1234H'),
      _AddrValue('2802H..2803H', '0102H'),
    ],
    exampleOutput: [
      _AddrValue('2804H..2805H', '1336H'),
      _AddrValue('2806H', '00H'),
    ],
  ),
  'Subtract Two 16-bit Numbers': _SampleProcedureInfo(
    inputs: ['2800H..2801H = minuend', '2802H..2803H = subtrahend'],
    outputs: ['2804H..2805H = difference', '2806H = borrow (00/01)'],
    exampleInput: [
      _AddrValue('2800H..2801H', '1234H'),
      _AddrValue('2802H..2803H', '0102H'),
    ],
    exampleOutput: [
      _AddrValue('2804H..2805H', '1132H'),
      _AddrValue('2806H', '00H'),
    ],
  ),
  'Multiply Two 8-bit Numbers': _SampleProcedureInfo(
    inputs: ['2500H = multiplicand', '2501H = multiplier'],
    outputs: ['2502H = product low byte', '2503H = product high byte'],
    exampleInput: [
      _AddrValue('2500H', '06H'),
      _AddrValue('2501H', '07H'),
    ],
    exampleOutput: [
      _AddrValue('2502H', '2AH'),
      _AddrValue('2503H', '00H'),
    ],
  ),
  'Divide Two 8-bit Numbers': _SampleProcedureInfo(
    inputs: ['2500H = dividend', '2501H = divisor (non-zero)'],
    outputs: ['2503H = quotient', '2502H = remainder'],
    exampleInput: [
      _AddrValue('2500H', '16H'),
      _AddrValue('2501H', '04H'),
    ],
    exampleOutput: [
      _AddrValue('2503H', '05H'),
      _AddrValue('2502H', '02H'),
    ],
  ),
  'Multiply Two 16-bit Numbers': _SampleProcedureInfo(
    inputs: ['2200H..2201H = multiplicand', '2202H..2203H = multiplier'],
    outputs: ['2204H..2205H = product low word', '2206H..2207H = product high word'],
    exampleInput: [
      _AddrValue('2200H..2201H', '0003H'),
      _AddrValue('2202H..2203H', '0004H'),
    ],
    exampleOutput: [
      _AddrValue('2204H..2205H', '000CH'),
      _AddrValue('2206H..2207H', '0000H'),
    ],
  ),
  'Divide Two 16-bit Numbers': _SampleProcedureInfo(
    inputs: ['2800H..2801H = dividend', '2802H..2803H = divisor (non-zero)'],
    outputs: ['2804H..2805H = quotient', '2806H..2807H = remainder'],
    exampleInput: [
      _AddrValue('2800H..2801H', '0014H'),
      _AddrValue('2802H..2803H', '0003H'),
    ],
    exampleOutput: [
      _AddrValue('2804H..2805H', '0006H'),
      _AddrValue('2806H..2807H', '0002H'),
    ],
  ),
};

class SampleProceduresSheet extends StatelessWidget {
  const SampleProceduresSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 2, 4, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SAMPLE PROCEDURES',
                  style: TextStyle(
                    color: kText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: kMono,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Open a sample and follow these quick steps to understand and run it.',
                  style: TextStyle(color: kTextDim, fontSize: 11, height: 1.4),
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: samplePrograms.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: kBorder.withValues(alpha: 0.7),
                ),
                itemBuilder: (_, i) {
                  final p = samplePrograms[i];
                  final info = _sampleProcedureByName[p.name];
                  return Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                      iconColor: kBlueBright,
                      collapsedIconColor: kTextDim,
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: kText,
                          fontFamily: kMono,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        p.description,
                        style: const TextStyle(
                          color: kTextDim,
                          fontSize: 10,
                        ),
                      ),
                      children: [
                        _step('1. Open ASM mode and choose SAMPLES.'),
                        _step('2. Select this sample and press ASSEMBLE.'),
                        _step('3. Read each instruction from top to bottom.'),
                        _step('4. Press RUN and observe registers/memory changes.'),
                        if (info != null) ...[
                          const SizedBox(height: 6),
                          _sectionTitle('INPUT SETUP'),
                          ...info.inputs.map(_kvLine),
                          const SizedBox(height: 6),
                          _sectionTitle('EXPECTED OUTPUT'),
                          ...info.outputs.map(_kvLine),
                          const SizedBox(height: 6),
                          _sectionTitle('PRACTICAL EXAMPLE'),
                          ...info.exampleInput
                              .map((e) => _kvLine(_fmtAddrVal(e))),
                          _kvLine('After RUN:'),
                          ...info.exampleOutput
                              .map((e) => _kvLine(_fmtAddrVal(e))),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, size: 14, color: kOrange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kTextDim,
                fontSize: 11,
                height: 1.35,
                fontFamily: kMono,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Text(
        text,
        style: const TextStyle(
          color: kBlueBright,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontFamily: kMono,
        ),
      ),
    );
  }

  Widget _kvLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record, size: 7, color: kOrange),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kTextDim,
                fontSize: 10.5,
                height: 1.3,
                fontFamily: kMono,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtAddrVal(_AddrValue v) => '${v.address} = ${v.value}';

}
