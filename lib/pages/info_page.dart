import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/backup_service.dart';
import '../services/tipjar_service.dart';
import '../widgets/watermark.dart';

/// Karo standard: the Info page (see _karo_standard/02_info_side.md).
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
  bool _loadingTips = true;

  @override
  void initState() {
    super.initState();
    _tipJar.onPurchased = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.thankYouForSupport),
        ),
      );
    };
    _tipJar.init().catchError((_) {}).whenComplete(() {
      if (mounted) setState(() => _loadingTips = false);
    });
  }

  @override
  void dispose() {
    _tipJar.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenLink)),
      );
    }
  }

  Future<void> _sendMail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      query: 'subject=${Uri.encodeComponent('Karos Habits')}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenMail)),
      );
    }
  }

  Widget _link(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }

  Widget _bullet(IconData icon, String title, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipButton(String label, String productId) {
    final price = _tipJar.priceFor(productId);
    final enabled = _tipJar.donationsAvailable;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? () => _tipJar.donate(productId) : null,
        icon: const Icon(Icons.favorite),
        label: Text(price == null ? label : '$label ($price)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final Widget tipSection;
    if (_loadingTips) {
      tipSection = const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      tipSection = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tipButton(l.donateNok(29), TipJarService.tip29),
          const SizedBox(height: 8),
          _tipButton(l.donateNok(59), TipJarService.tip59),
          const SizedBox(height: 8),
          _tipButton(l.donateNok(99), TipJarService.tip99),
          if (!_tipJar.donationsAvailable) ...[
            const SizedBox(height: 8),
            Text(l.tipsUnavailable, style: theme.textTheme.bodySmall),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.tabInfo), centerTitle: true),
      body: Stack(
        children: [
          const Watermark(),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Karos Habits', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(l.infoIntro),
              const SizedBox(height: 16),
              _bullet(
                Icons.notifications_outlined,
                l.infoRemindersTitle,
                l.infoRemindersText,
              ),
              _bullet(
                  Icons.widgets_outlined, l.infoWidgetTitle, l.infoWidgetText),
              const SizedBox(height: 12),
              Text(l.backupTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      onPressed: () => _backupService.exportBackup(context),
                      label: Text(l.exportData),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      onPressed: () => _backupService.importBackup(context),
                      label: Text(l.importData),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l.backupHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Text(l.linksTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _link(Icons.mail_outline, l.linkLetter, _sendMail),
              _link(Icons.public, l.linkWebsite, () => _openUrl(_website)),
              _link(
                Icons.privacy_tip,
                l.linkPrivacy,
                () => _openUrl(_privacy),
              ),
              _link(
                Icons.support_agent,
                l.linkSupport,
                () => _openUrl(_support),
              ),
              _link(Icons.apps, l.linkMoreApps, () => _openUrl(_moreApps)),
              const SizedBox(height: 12),
              Text(l.supportTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              tipSection,
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }
}
