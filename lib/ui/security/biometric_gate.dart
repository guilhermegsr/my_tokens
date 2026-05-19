import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../app_theme.dart';
import '../settings/settings_store.dart';

/// Requires device authentication (biometrics or device credential) before
/// the wrapped UI is shown, and re-locks whenever the app is backgrounded —
/// codes should never be readable from the app switcher or after handing
/// the unlocked phone to someone else.
///
/// If the device has no lock configured we let the user straight in:
/// trapping someone out of their own authenticator would be worse than the
/// (already absent) lock.
class BiometricGate extends StatefulWidget {
  const BiometricGate({super.key, required this.child});

  final Widget child;

  static int _systemInteractionDepth = 0;

  /// Suppresses the auto re-lock while the app itself drives a system UI
  /// that necessarily backgrounds us (file picker, share sheet). Without
  /// this, returning from the picker triggers the lock screen, tears down
  /// the page that started the flow, and the in-flight operation is lost.
  static Future<T> withoutAutoLock<T>(Future<T> Function() action) async {
    _systemInteractionDepth++;
    try {
      return await action();
    } finally {
      _systemInteractionDepth--;
    }
  }

  static bool get _autoLockSuspended => _systemInteractionDepth > 0;

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

enum _GateStatus { checking, locked, unlocked }

class _BiometricGateState extends State<BiometricGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();

  _GateStatus _status = _GateStatus.checking;
  bool _authInProgress = false;

  /// When the app was backgrounded, used to honour the lock grace period.
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _coldStart());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Our own picker/share sheet backgrounds the app; don't treat that as
    // the user leaving.
    if (BiometricGate._autoLockSuspended) return;

    final settings = context.read<SettingsStore>();
    if (!settings.lockEnabled) return;

    if (state == AppLifecycleState.paused &&
        _status == _GateStatus.unlocked) {
      if (settings.lockTimeout == LockTimeout.immediately) {
        setState(() => _status = _GateStatus.locked);
      } else {
        // Stay unlocked; recents is already blocked by FLAG_SECURE.
        // Re-locking is decided on resume, or — if the app is killed while
        // away — on the next cold start via the persisted timestamp.
        _backgroundedAt = DateTime.now();
        settings.recordBackgrounded();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_status == _GateStatus.locked) {
        _authenticate();
      } else if (_backgroundedAt != null) {
        final away = DateTime.now().difference(_backgroundedAt!);
        _backgroundedAt = null;
        if (away >= settings.lockTimeout.duration) {
          setState(() => _status = _GateStatus.locked);
          _authenticate();
        }
      }
    }
  }

  /// First check on launch. If the user picked a grace period and the app
  /// was backgrounded recently enough — even if it was then fully killed —
  /// we honour that window instead of demanding auth again, matching the
  /// behaviour of merely minimising the app.
  Future<void> _coldStart() async {
    final settings = context.read<SettingsStore>();
    await settings.ensureLoaded();
    if (settings.lockEnabled &&
        settings.lockTimeout != LockTimeout.immediately) {
      final last = settings.lastBackgroundedAt;
      if (last != null &&
          DateTime.now().difference(last) < settings.lockTimeout.duration) {
        if (mounted) setState(() => _status = _GateStatus.unlocked);
        return;
      }
    }
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_authInProgress) return;
    _authInProgress = true;
    final l10n = AppLocalizations.of(context);
    try {
      // Respect the user's choice to run without an app lock. Settings may
      // still be loading on first launch; default-locked is fail-secure.
      final settings = context.read<SettingsStore>();
      await settings.ensureLoaded();
      if (!settings.lockEnabled) {
        if (mounted) setState(() => _status = _GateStatus.unlocked);
        return;
      }
      if (!await _localAuth.isDeviceSupported()) {
        if (mounted) setState(() => _status = _GateStatus.unlocked);
        return;
      }
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: l10n.unlockReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (mounted) {
        setState(() => _status =
            didAuthenticate ? _GateStatus.unlocked : _GateStatus.locked);
      }
    } on PlatformException {
      if (mounted) setState(() => _status = _GateStatus.locked);
    } finally {
      _authInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_status == _GateStatus.unlocked) return widget.child;
    return _LockScreen(
      isChecking: _status == _GateStatus.checking,
      onUnlock: _authenticate,
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.isChecking, required this.onUnlock});

  final bool isChecking;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 56, color: palette.ring),
              const SizedBox(height: 20),
              Text(
                l10n.unlockTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: palette.title,
                ),
              ),
              const SizedBox(height: 28),
              if (isChecking)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.unlockButton),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(180, 48),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
