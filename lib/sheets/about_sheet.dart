import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const repoUrl = 'https://github.com/forgeVII-org/KIT85';
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(top: 8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: kBorder, borderRadius: BorderRadius.circular(2))),

            // Logo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: kGreen.withValues(alpha: 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: kGreen.withValues(alpha: 0.08),
                      blurRadius: 16,
                      spreadRadius: 2)
                ],
              ),
              child: const Center(
                  child: Text('85',
                      style: TextStyle(
                          color: kGreen,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: kMono))),
            ),
            const SizedBox(height: 12),
            const Text('KIT85',
                style: TextStyle(
                    color: kText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                    fontFamily: kMono)),
            const SizedBox(height: 4),
            const Text('Intel 8085 Microprocessor Kit Simulator',
                style:
                    TextStyle(color: kTextDim, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 20),

            // Info cards
            _infoRow('Version', kAppVersion, kGreen),
            const SizedBox(height: 8),
            _infoRow('Package', kPackageName, kBlueBright, copyable: true),
            const SizedBox(height: 8),
            _infoRow('Developer', 'forgeVII', kOrange),
            const SizedBox(height: 8),
            _infoRow('App', 'KIT85', kTextDim),
            const SizedBox(height: 8),
            _linkRow('Repository', repoUrl),
            const SizedBox(height: 20),

            // Feature pills
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('FEATURES',
                    style: TextStyle(
                        color: kTextDim,
                        fontSize: 9,
                        letterSpacing: 2,
                        fontFamily: kMono))),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final f in [
                'Tube-light startup animation',
                'Full 8085 CPU emulation',
                'Assembly language support',
                'Real kit workflow simulation',
                'Syntax highlighting in ASM editor',
                '10 sample programs library',
                'Complete 8085 opcode reference',
                'Number converter (DEC/HEX/BIN/OCT)',
                'Update notifications',
              ])
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder)),
                  child: Text(f,
                      style: const TextStyle(
                          color: kTextDim, fontSize: 11, fontFamily: kMono)),
                ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('BUILD INFO'),
            const SizedBox(height: 8),
            _infoRow('Build version', kAppVersion, kGreen),
            const SizedBox(height: 20),
            _sectionLabel('LICENSE'),
            const SizedBox(height: 8),
            _textCard(
                'License file is maintained in the project repository.\nOpen the Releases/Repository page for full license terms.'),
          ]),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) => Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(
              color: kTextDim,
              fontSize: 9,
              letterSpacing: 2,
              fontFamily: kMono)));

  Widget _textCard(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: kSurface2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorder)),
        child: Text(text,
            style: const TextStyle(
                color: kTextDim, fontSize: 11, height: 1.4, fontFamily: kMono)),
      );

  Widget _linkRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder)),
      child: Row(children: [
        Text(label,
            style: const TextStyle(
                color: kTextDim, fontSize: 12, fontFamily: kMono)),
        const Spacer(),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(value);
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: kBlueBright,
                    fontSize: 12,
                    fontFamily: kMono,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: kBlueBright)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: value)),
          child: const Icon(Icons.copy, color: kTextDim, size: 14),
        ),
      ]),
    );
  }

  Widget _infoRow(String label, String value, Color color,
      {bool copyable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder)),
      child: Row(children: [
        Text(label,
            style: const TextStyle(
                color: kTextDim, fontSize: 12, fontFamily: kMono)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: kMono,
                  fontWeight: FontWeight.bold)),
        ),
        if (copyable) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: value)),
            child: const Icon(Icons.copy, color: kTextDim, size: 14),
          ),
        ],
      ]),
    );
  }
}
