import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/privacy/screen_capture.dart';
import 'data/account_repository.dart';
import 'l10n/app_localizations.dart';
import 'ui/account_store.dart';
import 'ui/app_theme.dart';
import 'ui/home_page.dart';
import 'ui/security/biometric_gate.dart';
import 'ui/settings/settings_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The cryptography_flutter plugin auto-registers native AES-GCM/Argon2id
  // on Android & iOS (with a transparent Dart fallback elsewhere), which is
  // what keeps backup key derivation fast enough to not feel frozen.
  runApp(const MyTokensApp());
}

class MyTokensApp extends StatelessWidget {
  const MyTokensApp({super.key});

  static Locale _resolveLocale(Locale? deviceLocale, Iterable<Locale> _) {
    return deviceLocale?.languageCode == 'pt'
        ? const Locale('pt')
        : const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AccountStore(AccountRepository())..load(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsStore()..ensureLoaded()),
      ],
      child: Consumer<SettingsStore>(
        builder: (context, settings, _) => _ScreenCapturePreference(
          screenCaptureAllowed: settings.screenCaptureAllowed,
          child: MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            localeResolutionCallback: _resolveLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const BiometricGate(child: HomePage()),
          ),
        ),
      ),
    );
  }
}

class _ScreenCapturePreference extends StatefulWidget {
  const _ScreenCapturePreference({
    required this.screenCaptureAllowed,
    required this.child,
  });

  final bool screenCaptureAllowed;
  final Widget child;

  @override
  State<_ScreenCapturePreference> createState() =>
      _ScreenCapturePreferenceState();
}

class _ScreenCapturePreferenceState extends State<_ScreenCapturePreference> {
  @override
  void initState() {
    super.initState();
    _applyPreference();
  }

  @override
  void didUpdateWidget(covariant _ScreenCapturePreference oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.screenCaptureAllowed != widget.screenCaptureAllowed) {
      _applyPreference();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _applyPreference() {
    unawaited(ScreenCapture.setAllowed(widget.screenCaptureAllowed));
  }
}
