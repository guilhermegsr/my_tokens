import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/account.dart';
import '../../l10n/app_localizations.dart';
import '../account_store.dart';
import '../app_theme.dart';
import '../widgets/app_notification.dart';
import 'manual_entry_page.dart';
import 'scan_page.dart';

enum _EnrollmentMethod { scan, manual }

/// Drives account enrollment: pick QR vs. manual entry, receive the
/// resulting [Account] and persist it to the vault.
class AddAccountFlow {
  const AddAccountFlow._();

  /// Account IDs are local-only; a timestamp plus randomness is collision-
  /// safe enough without pulling in a UUID dependency.
  static String newAccountId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  static Future<void> start(BuildContext context) async {
    final store = context.read<AccountStore>();
    final method = await showModalBottomSheet<_EnrollmentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _MethodSheet(),
    );
    if (method == null || !context.mounted) return;

    final route = switch (method) {
      _EnrollmentMethod.scan =>
        MaterialPageRoute<Account>(builder: (_) => const ScanPage()),
      _EnrollmentMethod.manual =>
        MaterialPageRoute<Account>(builder: (_) => const ManualEntryPage()),
    };
    final account = await Navigator.of(context).push<Account>(route);
    if (account == null) return;

    final added = await store.add(account);
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      AppNotification.show(
        context,
        added
            ? l10n.accountAdded(account.displayName)
            : l10n.accountDuplicate,
        kind: added ? NotificationKind.success : NotificationKind.error,
      );
    }
  }
}

class _MethodSheet extends StatelessWidget {
  const _MethodSheet();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.addAccountButton,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.title,
              ),
            ),
            const SizedBox(height: 18),
            _MethodCard(
              icon: Icons.qr_code_scanner_rounded,
              title: l10n.addScanTitle,
              subtitle: l10n.addScanSubtitle,
              onTap: () => Navigator.pop(context, _EnrollmentMethod.scan),
            ),
            const SizedBox(height: 12),
            _MethodCard(
              icon: Icons.keyboard_rounded,
              title: l10n.addManualTitle,
              subtitle: l10n.addManualSubtitle,
              onTap: () => Navigator.pop(context, _EnrollmentMethod.manual),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
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
    return Material(
      color: palette.fieldFill,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.ring.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: palette.ring, size: 24),
              ),
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
                        color: palette.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
