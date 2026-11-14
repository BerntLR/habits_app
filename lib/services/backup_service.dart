import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

import '../bullpeak/widgets/bp_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'habit_service.dart';

class BackupService {
  static const String _backupMime = 'application/json';

  Future<void> exportBackup(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final service = context.read<HabitService>();
    final data = service.exportData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final fileName = _buildFileName();
    final file = XFile.fromData(
      utf8.encode(json),
      mimeType: _backupMime,
      name: fileName,
    );

    try {
      try {
        final location = await getSaveLocation(suggestedName: fileName);
        if (location == null) return; // cancelled
        await file.saveTo(location.path);
      } catch (_) {
        // Fallback where a save dialog is unavailable (iOS/Android): share sheet.
        await _shareFallback(file);
      }
    } catch (_) {
      if (!context.mounted) return;
      BPSnackbar.error(context, l.exportFailed);
    }
  }

  /// Asks for confirmation, then replaces all data with the chosen backup.
  /// On any error nothing is changed and a clear message is shown.
  Future<void> importBackup(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final service = context.read<HabitService>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.importConfirmTitle),
        content: Text(l.importConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.importButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final XFile? file;
    try {
      file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'JSON backup',
            extensions: ['json'],
            uniformTypeIdentifiers: ['public.json'],
          ),
        ],
      );
    } catch (_) {
      if (!context.mounted) return;
      BPSnackbar.error(context, l.importFailed);
      return;
    }
    if (file == null) return; // cancelled

    try {
      final json = await file.readAsString();
      final data = jsonDecode(json) as Map<String, dynamic>;
      await service.importData(data);
    } catch (_) {
      if (!context.mounted) return;
      BPSnackbar.error(context, l.importFailed);
      return;
    }

    if (!context.mounted) return;
    BPSnackbar.success(context, l.importSuccess);
  }

  Future<void> _shareFallback(XFile file) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${file.name}';
    final out = File(path);
    await out.writeAsBytes(await file.readAsBytes());

    await Share.shareXFiles([
      XFile(out.path, mimeType: _backupMime),
    ]);
  }

  String _buildFileName() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, "0");
    final m = now.month.toString().padLeft(2, "0");
    final d = now.day.toString().padLeft(2, "0");
    final hh = now.hour.toString().padLeft(2, "0");
    final mm = now.minute.toString().padLeft(2, "0");
    return "karos_habits_backup_$y-$m-${d}_$hh-$mm.json";
  }
}
