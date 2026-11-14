import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bullpeak/widgets/bp_button.dart';
import '../services/backup_service.dart';
import '../services/tipjar_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  static const String _email = 'post@teambullpeak.com';
  static const String _website = 'https://teambullpeak.com/';
  static const String _privacy =
      'https://teambullpeak.com/karos-habits/privacy';
  static const String _support = 'https://teambullpeak.com/home/support';
  static const String _moreApps = 'https://teambullpeak.com/apps';

  final BackupService _backupService = BackupService();
  final TipJarService _tipJar = TipJarService();

  late final Future<void> _tipInit = _tipJar.init();

  @override
  void initState() {
    super.initState();
    _tipJar.onPurchased = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you!')),
      );
    };
  }

  @override
  void dispose() {
    _tipJar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
                      onPressed: () async =>
                          _backupService.exportBackup(context),
                      label: 'Export data',
                      kind: BPButtonKind.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BPButton(
                      onPressed: () async =>
                          _backupService.importBackup(context),
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
              FutureBuilder<void>(
                future: _tipInit,
                builder: (context, snap) {
                  final loading = snap.connectionState != ConnectionState.done;
                  final available = _tipJar.donationsAvailable && !loading;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BPButton(
                        onPressed: available
                            ? () => _tipJar.donate(TipJarService.tip29)
                            : null,
                        label:
                            'Donate ${_tipJar.priceFor(TipJarService.tip29) ?? 'NOK 29'}',
                        kind: BPButtonKind.secondary,
                      ),
                      const SizedBox(height: 10),
                      BPButton(
                        onPressed: available
                            ? () => _tipJar.donate(TipJarService.tip59)
                            : null,
                        label:
                            'Donate ${_tipJar.priceFor(TipJarService.tip59) ?? 'NOK 59'}',
                        kind: BPButtonKind.secondary,
                      ),
                      const SizedBox(height: 10),
                      BPButton(
                        onPressed: available
                            ? () => _tipJar.donate(TipJarService.tip99)
                            : null,
                        label:
                            'Donate ${_tipJar.priceFor(TipJarService.tip99) ?? 'NOK 99'}',
                        kind: BPButtonKind.secondary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loading
                            ? 'Checking donation availability…'
                            : (available
                                ? 'Donations are available.'
                                : 'Donations are not available yet in this build.'),
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  );
                },
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
