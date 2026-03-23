import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class UpdateChecker {
  static const Duration _requestTimeout = Duration(seconds: 20);
  static const int _maxAttempts = 3;

  static Future<void> check(BuildContext context) async {
    final release = await _fetchLatestRelease();
    if (release == null) return;

    try {
      final latestTag =
          _normalizeVersion(release['tag_name']?.toString() ?? '');
      if (latestTag.isEmpty) return;

      final notes = release['body']?.toString() ?? '';
      final downloadUrl = _pickDownloadUrl(release);
      if (downloadUrl == null || downloadUrl.isEmpty) return;

      if (_isNewer(latestTag, kAppVersion)) {
        if (context.mounted) {
          _showDialog(context, latestTag, notes, downloadUrl);
        }
      } else {
        // App is up to date
        if (context.mounted) {
          _showSnackbar(context, '✓ App is up to date (v$kAppVersion)');
        }
      }
    } catch (e) {
      debugPrint('UpdateChecker: failed to process release payload: $e');
    }
  }

  static Future<Map<String, dynamic>?> _fetchLatestRelease() async {
    final latestUri = Uri.parse(
      'https://api.github.com/repos/$kGithubUser/$kGithubRepo/releases/latest',
    );
    final listUri = Uri.parse(
      'https://api.github.com/repos/$kGithubUser/$kGithubRepo/releases?per_page=10',
    );
    final htmlLatestUri = Uri.parse(
      'https://github.com/$kGithubUser/$kGithubRepo/releases/latest',
    );

    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final latestRes = await _get(latestUri);
        if (latestRes != null && latestRes.statusCode == 200) {
          final data = jsonDecode(latestRes.body);
          if (data is Map<String, dynamic>) return data;
        }

        final listRes = await _get(listUri);
        if (listRes != null && listRes.statusCode == 200) {
          final data = jsonDecode(listRes.body);
          if (data is List) {
            for (final item in data) {
              if (item is! Map<String, dynamic>) continue;
              final isDraft = item['draft'] == true;
              final isPre = item['prerelease'] == true;
              if (isDraft || isPre) continue;
              if (_pickDownloadUrl(item) != null) return item;
            }
          }
        }

        final htmlRes = await _get(htmlLatestUri);
        if (htmlRes != null && htmlRes.statusCode == 200) {
          final fallback = _parseLatestFromHtml(htmlRes.body);
          if (fallback != null) return fallback;
        }
      } catch (e) {
        debugPrint('UpdateChecker: attempt $attempt failed: $e');
      }

      if (attempt < _maxAttempts) {
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    return null;
  }

  static Future<http.Response?> _get(Uri uri) async {
    try {
      return await http.get(uri, headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        // Helps avoid network middleboxes/proxies dropping requests without UA.
        'User-Agent': '$kGithubRepo-android-update-checker',
      }).timeout(_requestTimeout);
    } catch (e) {
      debugPrint('UpdateChecker: request error for $uri: $e');
      return null;
    }
  }

  static String? _pickDownloadUrl(Map<String, dynamic> release) {
    final assets = release['assets'];
    if (assets is List) {
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name']?.toString().toLowerCase() ?? '';
        final url = asset['browser_download_url']?.toString();
        if (name.endsWith('.apk') && url != null && url.isNotEmpty) {
          return url;
        }
      }
    }

    // Fallback to release page if APK asset is missing or malformed.
    final htmlUrl = release['html_url']?.toString();
    if (htmlUrl != null && htmlUrl.isNotEmpty) return htmlUrl;

    return null;
  }

  static String _normalizeVersion(String version) {
    final cleaned = version
        .trim()
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .replaceFirst(RegExp(r'^\.+'), '')
        .replaceFirst(RegExp(r'\.+$'), '');
    return cleaned;
  }

  static Map<String, dynamic>? _parseLatestFromHtml(String html) {
    final match = RegExp("/releases/tag/([^\"'\\s<]+)").firstMatch(html);
    if (match == null) return null;

    final rawTag = match.group(1);
    if (rawTag == null || rawTag.isEmpty) return null;

    final decodedTag = Uri.decodeComponent(rawTag);
    return {
      'tag_name': decodedTag,
      'body': '',
      'html_url':
          'https://github.com/$kGithubUser/$kGithubRepo/releases/tag/$rawTag',
      'assets': const <Map<String, dynamic>>[],
    };
  }

  // compare version strings e.g. "1.1.0" > "1.0.0"
  static bool _isNewer(String latest, String current) {
    final l = latest
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    final c = current
        .split('.')
        .map((e) => int.tryParse(e.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0)
        .toList();
    for (int i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: Colors.white70, fontFamily: 'monospace', fontSize: 12)),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void _showDialog(
      BuildContext context, String version, String notes, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        title: Row(children: [
          const Icon(Icons.system_update, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 8),
          Text('Update Available',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontSize: 15,
                fontWeight: FontWeight.bold,
              )),
        ]),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: 'Current  ',
                    style: TextStyle(
                        color: Color(0xFF555555),
                        fontFamily: 'monospace',
                        fontSize: 12)),
                TextSpan(
                    text: 'v$kAppVersion',
                    style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                        fontSize: 12)),
              ])),
              const SizedBox(height: 2),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: 'Latest   ',
                    style: TextStyle(
                        color: Color(0xFF555555),
                        fontFamily: 'monospace',
                        fontSize: 12)),
                TextSpan(
                    text: 'v$version',
                    style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ])),
              if (notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('What\'s new:',
                    style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'monospace',
                        fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    notes.length > 200
                        ? '${notes.substring(0, 200)}...'
                        : notes,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'monospace',
                        fontSize: 11,
                        height: 1.4),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Download and install to update.\nYour data will be preserved.',
                style:
                    TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
              ),
            ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('LATER',
                style:
                    TextStyle(color: Colors.white24, fontFamily: 'monospace')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final releaseUrl = Uri.parse(
                    'https://github.com/$kGithubUser/$kGithubRepo/releases');
                await launchUrl(releaseUrl,
                    mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint('UpdateChecker: launch error: $e');
                if (context.mounted) {
                  _showSnackbar(context, 'Error opening browser');
                }
              }
            },
            child: const Text('DOWNLOAD',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }
}
