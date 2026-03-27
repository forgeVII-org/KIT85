import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../screens/kit_screen.dart';

class KitKeyboard extends StatelessWidget {
  final KitScreenState state;
  final bool hapticsEnabled;
  const KitKeyboard({
    super.key,
    required this.state,
    required this.hapticsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final s = state;
    return LayoutBuilder(builder: (_, c) {
      final kw = (c.maxWidth - 8) / 7;
      // Reserve 1 extra pixel and floor row height to avoid cumulative
      // floating-point rounding overflow on some device sizes.
      final kh = ((c.maxHeight - 9) / 4).floorToDouble();
      return Container(
          decoration: BoxDecoration(
            color: kSurface2,
            border:
                Border(top: BorderSide(color: kBorder.withValues(alpha: 0.7))),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(children: [
            _row(kh, [
              _fk('RESET', '', s.onReset, s.onReset, kw, kh, s),
              _fk('VCT', 'INT', s.onVct, s.onInt, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _shiftKey(kw, kh, s),
              _hk('C', kw, kh, s),
              _hk('D', kw, kh, s),
              _hk('E', kw, kh, s),
              _hk('F', kw, kh, s)
            ]),
            _row(kh, [
              _fk('EXREG', 'SI', s.onExReg, s.onSI, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _fk('INS', 'DATA', s.onInsData, s.onInsData, kw, kh, s),
              _fk('DEL', 'DATA', s.onDel, s.onDel, kw, kh, s),
              _hkd('8', 'H', kw, kh, s),
              _hkd('9', 'L', kw, kh, s),
              _hk('A', kw, kh, s),
              _hk('B', kw, kh, s)
            ]),
            _row(kh, [
              _fk('GO', '', s.onGo, s.onGo, kw, kh, s),
              _fk('B.M', '', s.onBM, s.onBM, kw, kh, s),
              _fk('REL', 'EXMEM', s.onRel, s.onExmem, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _hkd('4', 'PCH', kw, kh, s),
              _hkd('5', 'PCL', kw, kh, s),
              _hkd('6', 'SPH', kw, kh, s),
              _hkd('7', 'SPL', kw, kh, s)
            ]),
            _row(kh, [
              _fk('STR', 'PRE', s.onString, s.onPre, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _fk('MEMC', 'NEXT', s.onMemc, s.onNext, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _fk('FILL', '•', s.onFill, s.onDot, kw, kh, s,
                  fadeShiftTopWhenOff: true),
              _hk('0', kw, kh, s),
              _hk('1', kw, kh, s),
              _hkd('2', 'SER', kw, kh, s),
              _hk('3', kw, kh, s)
            ]),
          ]));
    });
  }

  Widget _row(double kh, List<Widget> keys) =>
      SizedBox(height: kh, child: Row(children: keys));

  Widget _hk(String label, double w, double h, KitScreenState s) => _kb(
        onTap: () => s.onHex(int.parse(label, radix: 16)),
        color: kSurface,
        w: w,
        h: h,
        child: Text(label,
            style: TextStyle(
                color: kText,
                fontSize: (w * 0.32).clamp(11, 20),
                fontWeight: FontWeight.bold,
                fontFamily: kMono)),
      );

  Widget _hkd(String main, String sub, double w, double h, KitScreenState s) =>
      _kb(
        onTap: () {
          final v = int.tryParse(main, radix: 16);
          if (v != null) s.onHex(v);
        },
        color: kSurface,
        w: w,
        h: h,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(main,
              style: TextStyle(
                  color: kText,
                  fontSize: (w * 0.28).clamp(10, 17),
                  fontWeight: FontWeight.bold,
                  fontFamily: kMono)),
          Text(sub,
              style: TextStyle(
                  color: kTextDim,
                  fontSize: (w * 0.18).clamp(7, 12),
                  fontFamily: kMono)),
        ]),
      );

  Widget _fk(String top, String bot, VoidCallback shiftCb, VoidCallback mainCb,
          double w, double h, KitScreenState s,
          {bool fadeShiftTopWhenOff = false}) =>
      _kb(
        onTap: () => s.shifted ? shiftCb() : mainCb(),
        color: kBlue,
        w: w,
        h: h,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (top.isNotEmpty)
            Text(top,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fadeShiftTopWhenOff && !s.shifted
                        ? Colors.white54
                        : Colors.white,
                    fontSize: (w * 0.18).clamp(7, 12),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontFamily: kMono)),
          if (bot.isNotEmpty)
            Text(bot,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fadeShiftTopWhenOff && s.shifted
                        ? Colors.white54
                        : Colors.white,
                    fontSize: (w * 0.17).clamp(7, 11),
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontFamily: kMono)),
        ]),
      );

  Widget _shiftKey(double w, double h, KitScreenState s) => _kb(
        onTap: s.onShift,
        color: s.shifted ? kBlueBright : kBlue,
        w: w,
        h: h,
        child: Text('SHF',
            style: TextStyle(
                color: s.shifted ? Colors.white : Colors.white54,
                fontSize: (w * 0.18).clamp(7, 12),
                fontWeight: FontWeight.bold,
                fontFamily: kMono)),
      );

  Widget _kb(
          {required VoidCallback onTap,
          required Color color,
          required double w,
          required double h,
          required Widget child}) =>
      Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                splashColor: kBlueBright.withValues(alpha: 0.16),
                highlightColor: kBlueBright.withValues(alpha: 0.08),
                onTap: () {
                  if (hapticsEnabled) {
                    HapticFeedback.lightImpact();
                  }
                  onTap();
                },
                child: Ink(
                  width: w - 4,
                  height: h - 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: 0.96),
                        color.withValues(alpha: 0.78),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: kBorder.withValues(alpha: 0.9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(child: child),
                ),
              )));
}
