import 'package:flutter/material.dart';
import '../constants.dart';

class ConverterSheet extends StatefulWidget {
  const ConverterSheet({super.key});
  @override
  State<ConverterSheet> createState() => _ConverterSheetState();
}

class _ConverterSheetState extends State<ConverterSheet> {
  final _dec = TextEditingController();
  final _hex = TextEditingController();
  final _bin = TextEditingController();
  final _oct = TextEditingController();
  bool _busy = false;

  void _set(int v) {
    _dec.text = v.toString();
    _hex.text = v.toRadixString(16).toUpperCase().padLeft(v > 255 ? 4 : 2, '0');
    _bin.text = v.toRadixString(2).padLeft(v > 255 ? 16 : 8, '0');
    _oct.text = v.toRadixString(8);
    setState(() {});
  }

  void _update(String raw, {int radix = 10}) {
    if (_busy) return;
    _busy = true;
    final s = raw.trim().replaceAll(RegExp(r'[Hh]'), '');
    final v = int.tryParse(s, radix: radix);
    if (v != null && v >= 0 && v <= 65535) {
      _set(v);
    } else if (raw.isEmpty) {
      _dec.clear();
      _hex.clear();
      _bin.clear();
      _oct.clear();
      setState(() {});
    }
    _busy = false;
  }

  @override
  void dispose() {
    _dec.dispose();
    _hex.dispose();
    _bin.dispose();
    _oct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: kBorder, borderRadius: BorderRadius.circular(2))),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(children: [
                const Icon(Icons.calculate, color: kOrange, size: 16),
                const SizedBox(width: 8),
                const Text('Number Converter',
                    style: TextStyle(
                        color: kText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ])),
          _field('DEC', _dec, (s) => _update(s), kBlueBright,
              TextInputType.number),
          const SizedBox(height: 8),
          _field('HEX', _hex, (s) => _update(s, radix: 16), kGreen,
              TextInputType.text),
          const SizedBox(height: 8),
          _field('BIN', _bin, (s) => _update(s, radix: 2), kOrange,
              TextInputType.number),
          const SizedBox(height: 8),
          _field('OCT', _oct, (s) => _update(s, radix: 8),
              const Color(0xFFCE93D8), TextInputType.number),
          const SizedBox(height: 14),
          _bitView(),
          const SizedBox(height: 12),
          _helpCard(),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _field(String lbl, TextEditingController ctrl,
          Function(String) onChange, Color c, TextInputType kt) =>
      Row(children: [
        SizedBox(
            width: 38,
            child: Text(lbl,
                style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontFamily: kMono,
                    fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
          controller: ctrl,
          keyboardType: kt,
          onChanged: onChange,
          style: TextStyle(
              color: c,
              fontSize: 13,
              fontFamily: kMono,
              fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: kSurface2,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: c.withValues(alpha: 0.3))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: c.withValues(alpha: 0.2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: c)),
          ),
        )),
      ]);

  Widget _bitView() {
    final v = int.tryParse(_dec.text.trim()) ?? 0;
    final bits = v.toRadixString(2).padLeft(8, '0').split('');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('BIT VIEW (8-bit)',
          style: TextStyle(
              color: kTextDim,
              fontSize: 9,
              letterSpacing: 1,
              fontFamily: kMono)),
      const SizedBox(height: 6),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(8, (i) {
            final on = bits[i] == '1';
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: on ? kOrange.withValues(alpha: 0.25) : kSurface2,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: on ? kOrange : kBorder),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(bits[i],
                        style: TextStyle(
                            color: on ? kOrange : kTextDim,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: kMono)),
                    Text('${7 - i}',
                        style: const TextStyle(
                            color: kTextDim, fontSize: 8, fontFamily: kMono)),
                  ]),
            );
          })),
    ]);
  }

  Widget _helpCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HOW TO USE',
                style: TextStyle(
                    color: kBlueBright,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontFamily: kMono,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('• Type in any one field (DEC / HEX / BIN / OCT).',
                style: TextStyle(color: kTextDim, fontSize: 11, height: 1.4)),
            Text('• Valid range: 0 to 65535 (16-bit).',
                style: TextStyle(color: kTextDim, fontSize: 11, height: 1.4)),
            Text('• 8-bit focus range: 0 to 255 (bit view shown below).',
                style: TextStyle(color: kTextDim, fontSize: 11, height: 1.4)),
            Text('• HEX accepts optional H suffix (example: FFH).',
                style: TextStyle(color: kTextDim, fontSize: 11, height: 1.4)),
            SizedBox(height: 6),
            Text('EXAMPLES',
                style: TextStyle(
                    color: kOrange,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontFamily: kMono,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('255 -> FF -> 11111111 -> 377',
                style: TextStyle(
                    color: kTextDim, fontSize: 11, fontFamily: kMono)),
            Text('4096 -> 1000 -> 1000000000000 -> 10000',
                style: TextStyle(
                    color: kTextDim, fontSize: 11, fontFamily: kMono)),
          ],
        ),
      );
}
