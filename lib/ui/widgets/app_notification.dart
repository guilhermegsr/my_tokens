import 'package:flutter/material.dart';

import '../app_theme.dart';

enum NotificationKind { success, error, info }

/// Themed, floating snackbars used everywhere instead of the bare Material
/// default, so feedback matches the light/dark palette and reads at a
/// glance (colored icon + tinted accent per outcome).
class AppNotification {
  const AppNotification._();

  static void show(
    BuildContext context,
    String message, {
    NotificationKind kind = NotificationKind.info,
  }) {
    showWith(ScaffoldMessenger.of(context), Theme.of(context), message,
        kind: kind);
  }

  /// Variant for call sites that must capture the messenger and theme
  /// before an `await` (e.g. the backup flow) to avoid using a
  /// [BuildContext] across async gaps.
  static void showWith(
    ScaffoldMessengerState messenger,
    ThemeData theme,
    String message, {
    NotificationKind kind = NotificationKind.info,
  }) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(_build(theme, message, kind));
  }

  static SnackBar _build(
    ThemeData theme,
    String message,
    NotificationKind kind,
  ) {
    final palette = theme.extension<AppPalette>()!;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF272B3A) : Colors.white;

    final accent = switch (kind) {
      NotificationKind.success => const Color(0xFF1FAD6B),
      NotificationKind.error => theme.colorScheme.error,
      NotificationKind.info => palette.ring,
    };
    final icon = switch (kind) {
      NotificationKind.success => Icons.check_circle_rounded,
      NotificationKind.error => Icons.error_rounded,
      NotificationKind.info => Icons.info_rounded,
    };

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surface,
      elevation: 8,
      duration: Duration(
        milliseconds: kind == NotificationKind.error ? 3500 : 2200,
      ),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.divider),
      ),
      content: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: palette.title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
