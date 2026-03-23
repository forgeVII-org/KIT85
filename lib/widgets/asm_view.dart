import 'package:flutter/material.dart';
import '../constants.dart';
import '../cpu/sample_programs.dart';
import '../screens/kit_screen.dart';
import '../sheets/series_picker_dialog.dart';

const _asmOpcodeColor = Color(0xFF56C8F5);
const _asmLabelColor = Color(0xFF57E389);
const _asmCommentColor = Color(0xFF7C90A3);
const _asmNumberColor = Color(0xFFFFB347);
const _asmRegisterColor = Color(0xFFA3B8FF);
const _asmDirectiveColor = Color(0xFF44D4C5);

final Set<String> _asmOpcodes = {
  'MOV',
  'MVI',
  'LDA',
  'STA',
  'LHLD',
  'SHLD',
  'LDAX',
  'STAX',
  'LXI',
  'ADD',
  'SUB',
  'ADI',
  'SUI',
  'CMP',
  'CMI',
  'ANA',
  'ANI',
  'ORA',
  'ORI',
  'XRA',
  'XRI',
  'RLC',
  'RRC',
  'RAL',
  'RAR',
  'DAA',
  'CMA',
  'SIM',
  'RIM',
  'INR',
  'DCR',
  'INX',
  'DCX',
  'PUSH',
  'POP',
  'XTHL',
  'XCHG',
  'SPHL',
  'PCHL',
  'JMP',
  'JC',
  'JNC',
  'JZ',
  'JNZ',
  'JP',
  'JM',
  'JPE',
  'JPO',
  'CALL',
  'CC',
  'CNC',
  'CZ',
  'CNZ',
  'CP',
  'CM',
  'CPE',
  'CPO',
  'RET',
  'RC',
  'RNC',
  'RZ',
  'RNZ',
  'RP',
  'RM',
  'RPE',
  'RPO',
  'RST',
  'HLT',
  'NOP',
  'IN',
  'OUT',
  'DI',
  'EI',
  'HALT',
  'WAIT',
};

final Set<String> _asmRegisters = {
  'A',
  'B',
  'C',
  'D',
  'E',
  'H',
  'L',
  'M',
  'SP',
  'PC',
  'F',
};

final Set<String> _asmDirectives = {
  'ORG',
  'END',
  'DB',
  'DW',
  'DS',
  'DEFINE',
};

final RegExp _asmTokenRegex = RegExp(
  r'(\s+|,|\(|\)|\+|-|\*|/|[A-Za-z_][A-Za-z0-9_]*:|0x[0-9A-Fa-f]+|[0-9A-Fa-f]+H|\d+|[A-Za-z_][A-Za-z0-9_]*|.)',
);

final RegExp _asmNumberRegex = RegExp(
  r'^(?:0x[0-9A-Fa-f]+|[0-9A-Fa-f]+H|\d+)$',
);

class AsmSyntaxController extends TextEditingController {
  AsmSyntaxController({super.text});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final baseStyle = style ??
        const TextStyle(
          color: kText,
          fontSize: 13,
          fontFamily: kMono,
          height: 1.5,
        );

    final lines = text.split('\n');
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      spans.addAll(_buildAsmLineSpans(lines[i], baseStyle));
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return TextSpan(style: baseStyle, children: spans);
  }
}

List<TextSpan> _buildAsmLineSpans(String line, TextStyle baseStyle) {
  final spans = <TextSpan>[];
  final commentIdx = line.indexOf(';');
  final codePart = commentIdx >= 0 ? line.substring(0, commentIdx) : line;
  final commentPart = commentIdx >= 0 ? line.substring(commentIdx) : null;

  for (final m in _asmTokenRegex.allMatches(codePart)) {
    final token = m.group(0)!;
    var color = baseStyle.color ?? kText;

    if (token.trim().isNotEmpty) {
      final upper = token.toUpperCase();
      if (token.endsWith(':')) {
        color = _asmLabelColor;
      } else if (_asmOpcodes.contains(upper)) {
        color = _asmOpcodeColor;
      } else if (_asmRegisters.contains(upper)) {
        color = _asmRegisterColor;
      } else if (_asmDirectives.contains(upper)) {
        color = _asmDirectiveColor;
      } else if (_asmNumberRegex.hasMatch(token)) {
        color = _asmNumberColor;
      }
    }

    spans.add(TextSpan(text: token, style: baseStyle.copyWith(color: color)));
  }

  if (commentPart != null) {
    spans.add(TextSpan(
      text: commentPart,
      style: baseStyle.copyWith(color: _asmCommentColor),
    ));
  }

  return spans;
}

class AsmView extends StatefulWidget {
  final KitScreenState state;
  final bool isLandscape;
  const AsmView({super.key, required this.state, required this.isLandscape});
  @override
  State<AsmView> createState() => _AsmViewState();
}

class _AsmViewState extends State<AsmView> {
  final _lineNumScroll = ScrollController(keepScrollOffset: false);
  final _editorScroll = ScrollController();
  bool _isLineNumbersScrolling = false;
  int _sourceLineCount = 1;
  final List<SampleProgram> _customSamples = [];

  static const _editorStrutStyle = StrutStyle(
    fontSize: 13,
    height: 1.5,
    fontFamily: kMono,
    forceStrutHeight: true,
  );

  int _computeSourceLineCount(String text) {
    final currentLines = text.split('\n').length;
    final includesTrailingEditableLine = text.endsWith('\n');
    return includesTrailingEditableLine ? currentLines : currentLines + 1;
  }

  int _extractOrigin(String source) {
    for (final line in source.split('\n')) {
      final t = line.trim().toUpperCase();
      if (t.startsWith('ORG')) {
        final p = t.split(RegExp(r'\s+'));
        if (p.length > 1) {
          return int.tryParse(p[1].replaceAll('H', ''), radix: 16) ?? 0x2000;
        }
      }
    }
    return 0x2000;
  }

  void _loadSampleProgram(SampleProgram sample) {
    final s = widget.state;
    s.setState(() {
      s.asmCtrl.text = sample.code;
      s.asmLines = [];
      s.asmError = '';
      s.asmOrigin = _extractOrigin(sample.code);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: kBlue,
      content: Text('Loaded sample: ${sample.name}',
          style: const TextStyle(
              color: Color(0xFF050505),
              fontFamily: kMono,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showSamplePrograms() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.78),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: kSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
          contentPadding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          title: const Text(
            'Sample Programs',
            style: TextStyle(
              color: kText,
              fontFamily: kMono,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          content: SizedBox(
            width: 460,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: samplePrograms.length + _customSamples.length,
              separatorBuilder: (context, index) => Divider(
                color: kBorder.withValues(alpha: 0.7),
                height: 1,
              ),
              itemBuilder: (_, i) {
                final isCustom = i >= samplePrograms.length;
                final sample = isCustom
                    ? _customSamples[i - samplePrograms.length]
                    : samplePrograms[i];
                return GestureDetector(
                  onLongPress: () =>
                      _showSampleMenu(ctx, sample, isCustom, setState),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      sample.name,
                      style: TextStyle(
                        color: isCustom ? kOrange : kText,
                        fontFamily: kMono,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      sample.description,
                      style: const TextStyle(
                        color: kTextDim,
                        fontFamily: kMono,
                        fontSize: 11,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _loadSampleProgram(sample);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSampleMenu(BuildContext ctx, SampleProgram sample, bool isCustom,
      void Function(void Function()) setState) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        content: SizedBox(
          width: 300,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.edit, color: kOrange, size: 18),
              title: const Text('Rename',
                  style:
                      TextStyle(color: kText, fontSize: 14, fontFamily: kMono)),
              onTap: () {
                Navigator.pop(dialogContext);
                _showRenameSampleDialog(sample, isCustom, setState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: kRed, size: 18),
              title: const Text('Delete',
                  style:
                      TextStyle(color: kRed, fontSize: 14, fontFamily: kMono)),
              onTap: () {
                Navigator.pop(dialogContext);
                _showDeleteSampleConfirm(sample, isCustom, setState);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _showRenameSampleDialog(SampleProgram sample, bool isCustom,
      void Function(void Function()) setState) {
    final ctrl = TextEditingController(text: sample.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Rename Sample',
            style: TextStyle(
                color: kText, fontFamily: kMono, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: kText, fontFamily: kMono, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Sample name',
            hintStyle: const TextStyle(
                color: kTextDim, fontFamily: kMono, fontSize: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kOrange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel',
                style: TextStyle(color: kTextDim, fontFamily: kMono)),
          ),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;

              if (isCustom) {
                // Rename custom sample directly
                final idx = _customSamples.indexOf(sample);
                if (idx >= 0) {
                  _customSamples[idx] = SampleProgram(
                    name: newName,
                    description: sample.description,
                    code: sample.code,
                  );
                }
              } else {
                // Convert built-in sample to custom with new name
                _customSamples.add(SampleProgram(
                  name: newName,
                  description: sample.description,
                  code: sample.code,
                ));
              }

              this.setState(() {});
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Rename',
                style: TextStyle(color: kOrange, fontFamily: kMono)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSampleConfirm(SampleProgram sample, bool isCustom,
      void Function(void Function()) setState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Sample',
            style: TextStyle(
                color: kText, fontFamily: kMono, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${sample.name}" permanently?',
          style:
              const TextStyle(color: kTextDim, fontFamily: kMono, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel',
                style: TextStyle(color: kTextDim, fontFamily: kMono)),
          ),
          TextButton(
            onPressed: () {
              if (isCustom) {
                _customSamples.remove(sample);
              } else {
                // Built-in samples can't be deleted from the global list,
                // but user can delete a copy if they renamed it
                // Just close the dialog
              }
              this.setState(() {});
              setState(() {});
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete',
                style: TextStyle(color: kRed, fontFamily: kMono)),
          ),
        ],
      ),
    );
  }

  void _showSaveNewSampleDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Save as Sample',
            style: TextStyle(
                color: kText, fontFamily: kMono, fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
            'Give this code a name:',
            style: TextStyle(color: kTextDim, fontFamily: kMono, fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            autofocus: true,
            style:
                const TextStyle(color: kText, fontFamily: kMono, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'My Custom Sample',
              hintStyle: const TextStyle(
                  color: kTextDim, fontFamily: kMono, fontSize: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kOrange),
              ),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel',
                style: TextStyle(color: kTextDim, fontFamily: kMono)),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              final s = widget.state;
              _customSamples.add(SampleProgram(
                name: name,
                description: 'Custom sample',
                code: s.asmCtrl.text,
              ));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: kGreen,
                content: Text('Saved as: $name',
                    style: const TextStyle(
                        color: Color(0xFF050505),
                        fontFamily: kMono,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                duration: const Duration(seconds: 2),
              ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Save',
                style: TextStyle(color: kGreen, fontFamily: kMono)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _sourceLineCount = _computeSourceLineCount(widget.state.asmCtrl.text);
    widget.state.asmCtrl.addListener(_updateLineCount);

    _editorScroll.addListener(() {
      _mirrorScroll(
        source: _editorScroll,
        target: _lineNumScroll,
        setTargetScrolling: (value) => _isLineNumbersScrolling = value,
        targetIsScrolling: () => _isLineNumbersScrolling,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mirrorScroll(
        source: _editorScroll,
        target: _lineNumScroll,
        setTargetScrolling: (value) => _isLineNumbersScrolling = value,
        targetIsScrolling: () => _isLineNumbersScrolling,
      );
    });
  }

  void _mirrorScroll({
    required ScrollController source,
    required ScrollController target,
    required void Function(bool value) setTargetScrolling,
    required bool Function() targetIsScrolling,
  }) {
    if (targetIsScrolling()) return;
    if (!source.hasClients || !target.hasClients) return;

    final offset = source.offset.clamp(0.0, target.position.maxScrollExtent);
    if ((target.offset - offset).abs() <= 0.5) return;

    setTargetScrolling(true);
    target.jumpTo(offset);
    setTargetScrolling(false);
  }

  void _updateLineCount() {
    final nextCount = _computeSourceLineCount(widget.state.asmCtrl.text);
    if (nextCount == _sourceLineCount) return;
    setState(() {
      _sourceLineCount = nextCount;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mirrorScroll(
        source: _editorScroll,
        target: _lineNumScroll,
        setTargetScrolling: (value) => _isLineNumbersScrolling = value,
        targetIsScrolling: () => _isLineNumbersScrolling,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AsmView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.asmCtrl != widget.state.asmCtrl) {
      oldWidget.state.asmCtrl.removeListener(_updateLineCount);
      _sourceLineCount = _computeSourceLineCount(widget.state.asmCtrl.text);
      widget.state.asmCtrl.addListener(_updateLineCount);
    }
  }

  @override
  void dispose() {
    widget.state.asmCtrl.removeListener(_updateLineCount);
    _lineNumScroll.dispose();
    _editorScroll.dispose();
    super.dispose();
  }

  void _sendToKit() {
    final s = widget.state;
    if (s.asmLines.isEmpty) s.asmLoad();
    if (s.asmError.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: kRed.withValues(alpha: 0.9),
        content: Text('Fix errors first: ${s.asmError}',
            style: const TextStyle(
                color: Color(0xFFFFF8F0),
                fontFamily: kMono,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        duration: const Duration(seconds: 3),
      ));
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => SeriesPickerDialog(
        currentOrigin: s.asmOrigin,
        onPick: (origin) {
          if (origin != s.asmOrigin) {
            if (!s.validateAsmSourceLineLimit()) {
              s.setState(() {});
              return;
            }
            s.asmOrigin = origin;
            final lines = s.asmSourceLines(s.asmCtrl.text);
            s.asmLines = s.asmEngine.assemble(lines, origin);
            final errs = s.asmLines.where((l) => l.error != null).toList();
            if (errs.isNotEmpty) {
              s.asmError =
                  errs.map((l) => '${l.mnemonic}: ${l.error}').join(', ');
              s.setState(() {});
              return;
            }
            if (!s.validateAsmMemoryBounds(s.asmLines, origin)) {
              s.setState(() {});
              return;
            }
          }
          s.sendToKit(origin);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: kGreen.withValues(alpha: 0.9),
            content: Text(
                'Loaded at ${origin.toRadixString(16).toUpperCase().padLeft(4, '0')}H',
                style: const TextStyle(
                    color: Color(0xFF050505),
                    fontFamily: kMono,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
            duration: const Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final lineLimit = KitScreenState.kAsmMaxSourceLines;
    final overLimit = _sourceLineCount > lineLimit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mirrorScroll(
        source: _editorScroll,
        target: _lineNumScroll,
        setTargetScrolling: (value) => _isLineNumbersScrolling = value,
        targetIsScrolling: () => _isLineNumbersScrolling,
      );
    });
    return SafeArea(
        bottom: false,
        child: Column(children: [
          // toolbar
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              border: Border(
                  bottom: BorderSide(color: kBorder.withValues(alpha: 0.8))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _btn('ASSEMBLE', kBlue, s.asmLoad),
                const SizedBox(width: 6),
                _btn('RUN', const Color(0xFF2E8657), s.asmRun),
                const SizedBox(width: 6),
                _btn(
                    'CLEAR',
                    kSurface2,
                    () => s.setState(() {
                          s.asmCtrl.clear();
                          s.asmLines = [];
                          s.asmError = '';
                        })),
                const SizedBox(width: 6),
                _btnWithLongPress('SAMPLES', const Color(0xFF385D9D),
                    _showSamplePrograms, _showSaveNewSampleDialog),
                const SizedBox(width: 6),
                _btn('→ KIT', const Color(0xFFAD5C10), _sendToKit),
                const SizedBox(width: 10),
                Text('LINES:$_sourceLineCount/$lineLimit',
                    style: TextStyle(
                        color: overLimit ? kRed : kTextDim,
                        fontSize: 10,
                        fontFamily: kMono,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Text('ORG:${s.asmOrigin.toRadixString(16).toUpperCase()}H',
                    style: const TextStyle(
                        color: kTextDim, fontSize: 10, fontFamily: kMono)),
              ]),
            ),
          ),
          if (s.asmError.isNotEmpty)
            Container(
                width: double.infinity,
                color: kRed.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(s.asmError,
                    style: const TextStyle(
                        color: kRed, fontSize: 11, fontFamily: kMono))),
          Expanded(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // line numbers
            Container(
              width: 44,
              color: kSurface2,
              child: _buildLineNumbers(),
            ),
            Container(width: 1, color: kBorder),
            // editor
            Expanded(
                flex: widget.isLandscape ? 6 : 5,
                child: Container(
                  color: kSurface,
                  child: TextField(
                    controller: s.asmCtrl,
                    scrollController: _editorScroll,
                    maxLines: null,
                    expands: true,
                    onChanged: (_) {
                      s.setState(() {});
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        _mirrorScroll(
                          source: _editorScroll,
                          target: _lineNumScroll,
                          setTargetScrolling: (value) =>
                              _isLineNumbersScrolling = value,
                          targetIsScrolling: () => _isLineNumbersScrolling,
                        );
                      });
                    },
                    cursorColor: kText,
                    textAlignVertical: TextAlignVertical.top,
                    strutStyle: _editorStrutStyle,
                    style: const TextStyle(
                      color: kText,
                      fontSize: 13,
                      fontFamily: kMono,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      border: InputBorder.none,
                      hintText:
                          '; Write 8085 assembly\nORG 2000H\n\nMVI A, 05H\n...',
                      hintStyle: TextStyle(
                        color: kTextDim,
                        fontSize: 12,
                        fontFamily: kMono,
                        height: 1.5,
                      ),
                    ),
                  ),
                )),
            Container(width: 1, color: kBorder),
            // hex output + highlighted preview
            Expanded(
                flex: widget.isLandscape ? 4 : 4, child: _buildOutputPanel(s)),
          ])),
          _buildRegBar(s),
        ]));
  }

  Widget _buildLineNumbers() {
    final nums =
        List.generate(KitScreenState.kAsmMaxSourceLines, (i) => '${i + 1}')
            .join('\n');
    return SingleChildScrollView(
      controller: _lineNumScroll,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 8, 6, 8),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          nums,
          textAlign: TextAlign.right,
          strutStyle: _editorStrutStyle,
          style: const TextStyle(
            color: kTextDim,
            fontSize: 13,
            fontFamily: kMono,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildOutputPanel(KitScreenState s) {
    if (s.asmLines.isEmpty) {
      return Container(
          color: kBg,
          child: const Center(
            child: Text('Press\nASSEMBLE',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: kTextDim, fontSize: 12, fontFamily: kMono)),
          ));
    }

    // syntax highlighted preview
    final srcLines = s.asmCtrl.text.split('\n');

    return Container(
        color: kBg,
        child: ListView.builder(
          padding: const EdgeInsets.all(4),
          itemCount: s.asmLines.length,
          itemBuilder: (_, i) {
            final l = s.asmLines[i];
            if (l.mnemonic == null) {
              // comment or empty — show highlighted source
              final src = i < srcLines.length ? srcLines[i].trim() : '';
              return _hlLine(src);
            }
            final hasErr = l.error != null;
            final addr = l.address != null
                ? l.address!.toRadixString(16).toUpperCase().padLeft(4, '0')
                : '    ';
            final bytes = l.bytes
                .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
                .join(' ');
            return RepaintBoundary(
                child: Container(
              color: hasErr ? kRed.withValues(alpha: 0.15) : Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
              child: Text('$addr  $bytes',
                  style: TextStyle(
                      color: hasErr ? kRed : kGreen,
                      fontSize: 11,
                      fontFamily: kMono,
                      letterSpacing: 0.5)),
            ));
          },
        ));
  }

  // Syntax highlighted line (for comment/label/empty rows in output panel)
  Widget _hlLine(String src) {
    if (src.isEmpty) return const SizedBox(height: 18);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: kText,
            fontSize: 11,
            fontFamily: kMono,
            height: 1.5,
          ),
          children: _buildAsmLineSpans(
            src,
            const TextStyle(
              color: kText,
              fontSize: 11,
              fontFamily: kMono,
              height: 1.5,
            ),
          ),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRegBar(KitScreenState s) => Container(
        color: kSurface,
        height: 28,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(children: [
            _rc('A', s.cpu.a),
            _rc('B', s.cpu.b),
            _rc('C', s.cpu.c),
            _rc('D', s.cpu.d),
            _rc('E', s.cpu.e),
            _rc('H', s.cpu.h),
            _rc('L', s.cpu.l),
            _rc('SP', s.cpu.sp),
            _rc('PC', s.cpu.pc),
            _rc('F', s.cpu.fl()),
          ]),
        ),
      );

  Widget _rc(String name, int val) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '$name:',
              style: const TextStyle(
                  color: kTextDim, fontSize: 10, fontFamily: kMono)),
          TextSpan(
              text: val
                  .toRadixString(16)
                  .toUpperCase()
                  .padLeft(name == 'SP' || name == 'PC' ? 4 : 2, '0'),
              style: const TextStyle(
                  color: kGreen,
                  fontSize: 10,
                  fontFamily: kMono,
                  fontWeight: FontWeight.bold)),
        ])),
      );

  Widget _btn(String label, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder.withValues(alpha: 0.85))),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: kMono)),
        ),
      );

  Widget _btnWithLongPress(String label, Color color, VoidCallback onTap,
          VoidCallback onLongPress) =>
      GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder.withValues(alpha: 0.85))),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontFamily: kMono)),
        ),
      );
}
