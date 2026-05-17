import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../app_theme.dart';
import 'settings_store.dart';

/// App preferences: turn the lock off, choose the lock grace period, and
/// pick the theme. Reached from the side menu.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsStore>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _Section(
            title: l10n.settingsSecurity,
            children: [
              _SwitchRow(
                icon: Icons.lock_outline,
                title: l10n.settingsAppLock,
                subtitle: l10n.settingsAppLockSubtitle,
                value: settings.lockEnabled,
                onChanged: settings.setLockEnabled,
              ),
            ],
          ),
          // The grace period is meaningless without the lock, so it folds
          // away when the lock is off instead of sitting there disabled.
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: settings.lockEnabled
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _Section(
              title: l10n.settingsAutoLock,
              children: [
                for (final timeout in LockTimeout.values)
                  _ChoiceRow(
                    label: _timeoutLabel(l10n, timeout),
                    selected: settings.lockTimeout == timeout,
                    onTap: () => settings.setLockTimeout(timeout),
                  ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
          _Section(
            title: l10n.settingsAppearance,
            children: [
              _ChoiceRow(
                label: l10n.settingsThemeSystem,
                selected: settings.themeMode == ThemeMode.system,
                onTap: () => settings.setThemeMode(ThemeMode.system),
              ),
              _ChoiceRow(
                label: l10n.settingsThemeLight,
                selected: settings.themeMode == ThemeMode.light,
                onTap: () => settings.setThemeMode(ThemeMode.light),
              ),
              _ChoiceRow(
                label: l10n.settingsThemeDark,
                selected: settings.themeMode == ThemeMode.dark,
                onTap: () => settings.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeoutLabel(AppLocalizations l10n, LockTimeout t) {
    switch (t) {
      case LockTimeout.immediately:
        return l10n.settingsLockImmediately;
      case LockTimeout.after30s:
        return l10n.settingsLockAfter30s;
      case LockTimeout.after1m:
        return l10n.settingsLockAfter1m;
      case LockTimeout.after5m:
        return l10n.settingsLockAfter5m;
    }
  }
}

/// A titled, rounded card grouping related rows — the visual language used
/// by the rest of the app (edit account, drawer).
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: palette.subtitle,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: palette.fieldFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: palette.divider,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Row(
        children: [
          Icon(icon, color: palette.ring, size: 22),
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
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: palette.subtitle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? palette.ring : palette.title,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: palette.ring, size: 22),
          ],
        ),
      ),
    );
  }
}
