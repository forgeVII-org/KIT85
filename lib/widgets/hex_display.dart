import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/enums.dart';
import '../screens/kit_screen.dart';

class HexDisplay extends StatelessWidget {
  final KitScreenState state;
  const HexDisplay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    List<String> addrChars = s.execDone
        ? ['E', ' ', ' ', ' ']
        : s.addrOn
            ? s.addrBuf
                .toRadixString(16)
                .toUpperCase()
                .padLeft(4, '0')
                .split('')
            : List.filled(4, '-');

    final dataVal = s.dataOn
        ? (s.kstate == KitState.exreg ? s.getRegVal(s.regView) : s.dataBuf)
        : null;
    List<String> dataChars = dataVal != null
        ? dataVal.toRadixString(16).toUpperCase().padLeft(2, '0').split('')
        : List.filled(2, '-');

    return GestureDetector(
      onLongPress: s.addrOn ? s.copyDisplay : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBg, kSurface.withValues(alpha: 0.75)],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ...addrChars.map(_seg),
          const SizedBox(width: 10),
          Container(width: 2, height: 46, color: kRedDim),
          const SizedBox(width: 10),
          ...dataChars.map(_seg),
          if (s.addrOn) ...[
            const SizedBox(width: 8),
            Icon(Icons.copy_rounded,
                size: 13, color: kTextDim.withValues(alpha: 0.45)),
          ],
        ]),
      ),
    );
  }

  Widget _seg(String ch) {
    final dim = ch == '-' || ch == ' ';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 36,
      height: 52,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kSurface2, kSurface],
          ),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: kBorder.withValues(alpha: 0.95))),
      child: Center(
          child: Text(ch,
              style: TextStyle(
                color: dim ? kRedDim : kRed,
                fontSize: 33,
                fontWeight: FontWeight.bold,
                fontFamily: kMono,
                shadows: dim ? const [] : [Shadow(color: kRed, blurRadius: 7)],
              ))),
    );
  }
}

class DecStrip extends StatelessWidget {
  final KitScreenState state;
  const DecStrip({super.key, required this.state});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: kSurface,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Text('DEC  ${state.addrBuf.toString().padLeft(5)}',
            style: const TextStyle(
                color: kTextDim,
                fontSize: 10,
                fontFamily: kMono,
                letterSpacing: 1.4),
            textAlign: TextAlign.right),
      );
}
