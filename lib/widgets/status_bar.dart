import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/enums.dart';
import '../screens/kit_screen.dart';

class KitStatusBar extends StatelessWidget {
  final KitScreenState state;
  const KitStatusBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final modeStr = s.kstate == KitState.exmem
        ? 'EXMEM'
        : s.kstate == KitState.go
            ? 'GO'
            : s.kstate == KitState.exreg
                ? 'REG:${s.regView.label}'
                : s.shifted
                    ? 'SHIFT'
                    : 'IDLE';
    return Container(
      width: double.infinity,
      color: kSurface2,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: s.status.contains('HALT') ? kRed : kGreen,
              boxShadow: [
                BoxShadow(
                  color: (s.status.contains('HALT') ? kRed : kGreen)
                      .withValues(alpha: 0.55),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(s.status,
              style: const TextStyle(
                  color: kGreen,
                  fontSize: 11,
                  fontFamily: kMono,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Text(modeStr,
              style: const TextStyle(
                  color: kTextDim,
                  fontSize: 10,
                  letterSpacing: 0.9,
                  fontFamily: kMono)),
        ),
      ]),
    );
  }
}
