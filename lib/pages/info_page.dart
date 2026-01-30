import 'package:flutter/material.dart';

import '../bullpeak/widgets/bp_button.dart';
import '../services/backup_service.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final backupService = BackupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
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
                            backupService.exportBackup(context),
                        label: 'Export data',
                        kind: BPButtonKind.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BPButton(
                        onPressed: () async =>
                            backupService.importBackup(context),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

