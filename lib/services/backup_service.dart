import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupService {
  static const String _schemaVersionKey = 'schemaVersion';
  static const int _currentSchemaVersion = 1;

  Future<void> exportBackup(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final Map<String, dynamic> data = {
        _schemaVersionKey: _currentSchemaVersion,
        'createdAt': DateTime.now().toIso8601String(),
        'prefs': <String, dynamic>{},
      };

      final Map<String, dynamic> prefsMap =
          data['prefs'] as Map<String, dynamic>;

      for (final key in keys) {
        final value = prefs.get(key);
        if (value is String) {
          prefsMap[key] = {'type': 'string', 'value': value};
        } else if (value is bool) {
          prefsMap[key] = {'type': 'bool', 'value': value};
        } else if (value is int) {
          prefsMap[key] = {'type': 'int', 'value': value};
        } else if (value is double) {
          prefsMap[key] = {'type': 'double', 'value': value};
        } else if (value is List<String>) {
          prefsMap[key] = {'type': 'stringList', 'value': value};
        }
      }

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '')
          .replaceAll('.', '')
          .replaceAll('-', '');
      final filePath = '${tempDir.path}/habits_backup_$timestamp.json';

      final file = File(filePath);
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Habits-app backup',
      );
    } catch (e) {
      _showSnack(context, 'Klarte ikke a eksportere backup.');
    }
  }

  Future<void> importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final path = result.files.single.path;
      if (path == null) {
        _showSnack(context, 'Fant ikke filsti for backup.');
        return;
      }

      final file = File(path);
      final content = await file.readAsString();

      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        _showSnack(context, 'Ugyldig backup-fil.');
        return;
      }

      final prefsData = decoded['prefs'];
      if (prefsData is! Map<String, dynamic>) {
        _showSnack(context, 'Ugyldig backup-struktur.');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (final entry in prefsData.entries) {
        final String key = entry.key;
        final dynamic valueMap = entry.value;
        if (valueMap is! Map<String, dynamic>) continue;

        final String? type = valueMap['type'] as String?;
        final dynamic value = valueMap['value'];

        switch (type) {
          case 'string':
            if (value is String) {
              await prefs.setString(key, value);
            }
            break;
          case 'bool':
            if (value is bool) {
              await prefs.setBool(key, value);
            }
            break;
          case 'int':
            if (value is int) {
              await prefs.setInt(key, value);
            }
            break;
          case 'double':
            if (value is num) {
              await prefs.setDouble(key, value.toDouble());
            }
            break;
          case 'stringList':
            if (value is List) {
              final list = value.whereType<String>().toList();
              await prefs.setStringList(key, list);
            }
            break;
          default:
            break;
        }
      }

      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Backup importert'),
            content: const Text(
              'Backup er importert. Start appen pa nytt for at endringene skal vises.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showSnack(context, 'Klarte ikke a importere backup.');
    }
  }

  void _showSnack(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
