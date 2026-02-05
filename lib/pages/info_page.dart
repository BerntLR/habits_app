import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bullpeak/widgets/bp_button.dart';
import '../services/backup_service.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  static const String _email = 'post@teambullpeak.com';
  static const String _website = 'https://teambullpeak.com/';
  static const String _privacy = 'https://teambullpeak.com/karos-habits/privacy';
  static const String _support = 'https://teambullpeak.com/home/support';
  static const String _moreApps = 'https://teambullpeak.com/apps';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final backupService = BackupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/watermark_dark.png'
                    : 'assets/watermark_light.png',
                width: MediaQuery.of(context).size.width * 0.75,
                fit: BoxFit.contain,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              const Text(
                'Karos Habits',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Track habits day by day. Review your history in Stats.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),

              const SizedBox(height: 20),
              const Text(
                'Backup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BPButton(
                      onPressed: () async => backupService.exportBackup(context),
                      label: 'Export data',
                      kind: BPButtonKind.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BPButton(
                      onPressed: () async => backupService.importBackup(context),
                      label: 'Import data',
                      kind: BPButtonKind.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Export creates a JSON backup file. Import replaces your current data.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),

              const SizedBox(height: 24),
              const Text(
                'Links',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: () => _sendMail(context),
                label: 'Send me a letter',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: () => _openLink(context, _website),
                label: 'Website',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: () => _openLink(context, _privacy),
                label: 'Privacy policy',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: () => _openLink(context, _support),
                label: 'Support',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: () => _openLink(context, _moreApps),
                label: 'More from BullPeak',
                kind: BPButtonKind.secondary,
              ),

              const SizedBox(height: 24),
              const Text(
                'Support the developer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: null,
                label: 'Donate NOK 29',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: null,
                label: 'Donate NOK 59',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              BPButton(
                onPressed: null,
                label: 'Donate NOK 99',
                kind: BPButtonKind.secondary,
              ),
              const SizedBox(height: 10),
              Text(
                'Donations are not available yet in this build.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  static Future<void> _sendMail(BuildContext context) async {
    final subject = Uri.encodeComponent('Karos Habits');
    final uri = Uri.parse('mailto:$_email?subject=$subject');

    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open mail app')),
      );
    }
  }
}

