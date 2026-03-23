import 'package:flutter/material.dart';
import '../constants.dart';

class SeriesPickerDialog extends StatefulWidget {
  final int currentOrigin;
  final Function(int) onPick;
  const SeriesPickerDialog(
      {super.key, required this.currentOrigin, required this.onPick});
  @override
  State<SeriesPickerDialog> createState() => _SeriesPickerDialogState();
}

class _SeriesPickerDialogState extends State<SeriesPickerDialog> {
  late int _selected;
  bool _custom = false;
  final _ctrl = TextEditingController();
  String _err = '';

  static const _presets = [
    {'label': '2000H', 'value': 0x2000},
    {'label': '0000H', 'value': 0x0000},
    {'label': '8000H', 'value': 0x8000},
    {'label': 'Custom', 'value': -1},
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.currentOrigin;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    int origin = _selected;
    if (_custom) {
      final s = _ctrl.text.trim().toUpperCase().replaceAll('H', '');
      origin = int.tryParse(s, radix: 16) ?? -1;
      if (origin < 0 || origin > 0xFFFF) {
        setState(() => _err = 'Invalid address (use 0000H to FFFFH)');
        return;
      }
    }
    Navigator.pop(context);
    widget.onPick(origin);
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: kSurface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: kBorder)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.memory, color: kOrange, size: 16),
                    const SizedBox(width: 8),
                    const Text('Load into Series',
                        style: TextStyle(
                            color: kText,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:
                            const Icon(Icons.close, color: kTextDim, size: 18)),
                  ]),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose where assembled bytes will be loaded in KIT memory.\nPreset values are quick-start addresses. Custom accepts 0000H to FFFFH.',
                    style:
                        TextStyle(color: kTextDim, fontSize: 11, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  const Text('SELECT ADDRESS SERIES:',
                      style: TextStyle(
                          color: kTextDim, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((p) {
                        final isCustom = p['value'] == -1;
                        final sel = isCustom
                            ? _custom
                            : (!_custom && _selected == p['value']);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isCustom) {
                              _custom = true;
                            } else {
                              _custom = false;
                              _selected = p['value'] as int;
                            }
                            _err = '';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                                color: sel
                                    ? kOrange.withValues(alpha: 0.2)
                                    : kSurface2,
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: sel ? kOrange : kBorder)),
                            child: Text(p['label'] as String,
                                style: TextStyle(
                                    color: sel ? kOrange : kTextDim,
                                    fontSize: 13,
                                    fontFamily: kMono,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList()),
                  if (_custom) ...[
                    const SizedBox(height: 10),
                    TextField(
                        controller: _ctrl,
                        style: const TextStyle(
                            color: kText, fontFamily: kMono, fontSize: 13),
                        decoration: InputDecoration(
                            hintText: 'e.g. 4000H',
                            hintStyle:
                                const TextStyle(color: kTextDim, fontSize: 12),
                            filled: true,
                            fillColor: kSurface2,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: kBorder)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(color: kBorder)))),
                  ],
                  if (_err.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(_err,
                        style: const TextStyle(
                            color: kRed, fontSize: 11, fontFamily: kMono))
                  ],
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    _btn('CANCEL', kSurface2, kTextDim,
                        () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    _btn('LOAD →KIT', kOrange, Colors.white, _confirm),
                  ]),
                ]),
          ),
        ),
      );

  Widget _btn(String t, Color bg, Color fg, VoidCallback cb) => GestureDetector(
      onTap: cb,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
          child: Text(t,
              style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5))));
}
