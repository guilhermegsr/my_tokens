import 'package:flutter/material.dart';

/// MyTokens light and dark themes.
class AppTheme {
  const AppTheme._();

  static const _accent = Color(0xFF3D52F0); // ring + FAB indigo

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: const Color(0xFFF7F8FA),
        fieldFill: const Color(0xFFEDEFF3),
        title: const Color(0xFF1B1D28),
        subtitle: const Color(0xFF9AA0AC),
        divider: const Color(0xFFE6E8EC),
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: const Color(0xFF15171F),
        fieldFill: const Color(0xFF222533),
        title: const Color(0xFFF4F5F7),
        subtitle: const Color(0xFF8A8F9E),
        divider: const Color(0xFF2A2D3A),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color fieldFill,
    required Color title,
    required Color subtitle,
    required Color divider,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
    ).copyWith(primary: _accent, surface: background);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      // No "pressed" ripple/highlight on any tappable surface — taps stay
      // visually flat across buttons, the FAB and the token/search rows.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      extensions: [
        AppPalette(
          title: title,
          subtitle: subtitle,
          fieldFill: fieldFill,
          ring: _accent,
          divider: divider,
        ),
      ],
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
    );
  }
}

/// Brand colors that don't map cleanly onto Material's [ColorScheme].
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.title,
    required this.subtitle,
    required this.fieldFill,
    required this.ring,
    required this.divider,
  });

  final Color title;
  final Color subtitle;
  final Color fieldFill;
  final Color ring;
  final Color divider;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>()!;

  @override
  AppPalette copyWith({
    Color? title,
    Color? subtitle,
    Color? fieldFill,
    Color? ring,
    Color? divider,
  }) =>
      AppPalette(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        fieldFill: fieldFill ?? this.fieldFill,
        ring: ring ?? this.ring,
        divider: divider ?? this.divider,
      );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      title: Color.lerp(title, other.title, t)!,
      subtitle: Color.lerp(subtitle, other.subtitle, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
