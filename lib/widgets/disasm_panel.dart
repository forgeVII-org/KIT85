import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/kit_screen.dart';

class DisasmPanel extends StatefulWidget {
  final KitScreenState state;
  const DisasmPanel({super.key, required this.state});
  @override
  State<DisasmPanel> createState() => _DisasmPanelState();
}

class _DisasmPanelState extends State<DisasmPanel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final lines = s.getDisasm();

    int hlAddr = s.addrBuf;
    int hlIdx = 0;
    for (int i = 0; i < lines.length; i++) {
      final a = lines[i]['addr'] as int;
      final sz = (lines[i]['size'] as int?) ?? 1;
      if (s.addrBuf >= a && s.addrBuf < a + sz) {
        hlAddr = a;
        hlIdx = i;
        break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      const lineH = 19.0;
      final offset =
          ((hlIdx - 4) * lineH).clamp(0.0, _scroll.position.maxScrollExtent);
      _scroll.jumpTo(offset);
    });

    return Container(
      height: 146,
      decoration: BoxDecoration(
        color: kSurface,
        border:
            Border(bottom: BorderSide(color: kBorder.withValues(alpha: 0.9))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 2),
            child: Text('DISASM',
                style: TextStyle(
                    color: kGreen.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    fontFamily: kMono))),
        Expanded(
            child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: lines.length,
          itemBuilder: (_, i) {
            final l = lines[i];
            final active = l['addr'] == hlAddr;
            final addr = l['addr'] as int;
            return RepaintBoundary(
                child: GestureDetector(
              onLongPress: () => s.jumpToAddr(addr),
              child: Container(
                height: 19,
                color: active
                    ? kGreen.withValues(alpha: 0.12)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(children: [
                  Expanded(
                      child: Text(
                    '${addr.toRadixString(16).toUpperCase().padLeft(4, '0')}  ${l['line']}',
                    style: TextStyle(
                        color: active ? kGreen : kTextDim,
                        fontSize: 11,
                        fontFamily: kMono,
                        letterSpacing: 0.35),
                  )),
                  if (!active)
                    Icon(Icons.arrow_upward,
                        size: 10, color: kTextDim.withValues(alpha: 0.2)),
                ]),
              ),
            ));
          },
        )),
      ]),
    );
  }
}

class DisasmToggle extends StatelessWidget {
  final KitScreenState state;
  const DisasmToggle({super.key, required this.state});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () =>
            // ignore: invalid_use_of_protected_member
            state.setState(() => state.disasmVisible = !state.disasmVisible),
        child: Container(
          width: double.infinity,
          color: kSurface,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(children: [
            Icon(state.disasmVisible ? Icons.visibility_off : Icons.visibility,
                color: kTextDim, size: 12),
            const SizedBox(width: 6),
            Text(state.disasmVisible ? 'HIDE' : 'SHOW',
                style: const TextStyle(
                    color: kTextDim,
                    fontSize: 9,
                    letterSpacing: 1,
                    fontFamily: kMono)),
            const SizedBox(width: 8),
            Expanded(
                child: Text('ASM-guided decode active',
                    style: TextStyle(
                        color: kGreen.withValues(alpha: 0.65),
                        fontSize: 9,
                        fontFamily: kMono),
                    overflow: TextOverflow.ellipsis)),
            const Text('hold to jump',
                style:
                    TextStyle(color: kTextDim, fontSize: 9, fontFamily: kMono)),
          ]),
        ),
      );
}
