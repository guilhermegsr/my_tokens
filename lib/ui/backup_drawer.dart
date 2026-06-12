import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../l10n/app_localizations.dart';
import 'app_theme.dart';

class BackupDrawer extends StatelessWidget {
  const BackupDrawer({
    super.key,
    required this.onExport,
    required this.onImport,
    required this.onSettings,
  });

  /// Resolved once from the build's own metadata, not hardcoded — a
  /// literal here silently went stale across releases.
  static final Future<String> _appVersion =
      PackageInfo.fromPlatform().then((i) => i.version);

  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                l10n.drawerTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: palette.title,
                ),
              ),
              const SizedBox(height: 36),
              _DrawerAction(
                icon: Icons.file_upload_outlined,
                title: l10n.drawerExport,
                subtitle: l10n.drawerExportSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  onExport();
                },
              ),
              const SizedBox(height: 8),
              _DrawerAction(
                icon: Icons.file_download_outlined,
                title: l10n.drawerImport,
                subtitle: l10n.drawerImportSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  onImport();
                },
              ),
              const SizedBox(height: 8),
              _DrawerAction(
                icon: Icons.settings_outlined,
                title: l10n.drawerSettings,
                subtitle: l10n.drawerSettingsSubtitle,
                onTap: () {
                  Navigator.pop(context);
                  onSettings();
                },
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FutureBuilder<String>(
                    future: _appVersion,
                    builder: (context, snapshot) => Text(
                      snapshot.hasData
                          ? l10n.appVersionLabel(snapshot.data!)
                          : '',
                      style:
                          TextStyle(fontSize: 12, color: palette.subtitle),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerAction extends StatelessWidget {
  const _DrawerAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: palette.ring, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: palette.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: palette.subtitle),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: palette.subtitle, size: 22),
          ],
        ),
      ),
    );
  }
}
