import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Detects a device clock that is out of sync, which silently breaks every
/// TOTP code. Two independent, offline signals are combined:
///
/// 1. **OS-synced network time.** On Android we read the time the operating
///    system itself obtained via NTP (`SystemClock.currentNetworkTimeClock`)
///    through a platform channel. This needs no `INTERNET` permission for
///    the app and catches an absolute offset in either direction. iOS has
///    no public equivalent, so it returns null there.
///
/// 2. **Boot-anchored monotonic cross-check.** A monotonic clock cannot be
///    changed by the user. Persisting `(wallClock, monotonic)` lets us
///    assert that the wall clock advanced at least as much as the
///    provably-elapsed monotonic time; falling short means it was set back.
///    A highest-ever watermark covers reboots, where the monotonic clock
///    resets and the cross-check cannot span the gap.
///
/// Accepted limitation: a forward jump on iOS (no OS time, monotonic can't
/// distinguish it from legitimate sleep) is not detected.
class ClockGuard {
  ClockGuard._();

  static final ClockGuard instance = ClockGuard._();

  static const _channel = MethodChannel('net.guilhermegomes.mytokens/clock');

  /// Allowed absolute offset vs. OS network time. Comfortably above the
  /// 30 s TOTP window so routine NTP correction isn't flagged.
  static const _absoluteToleranceMs = 60 * 1000;

  /// Slack for the monotonic/watermark comparisons, absorbing scheduling
  /// jitter while still catching a clock moved back by minutes or more.
  static const _driftToleranceMs = 120 * 1000;

  static const _stateFileName = 'clock_state';

  File? _cachedFile;

  /// Evaluates both signals, persists the new baseline, and returns whether
  /// the clock looks wrong. Safe to call on every launch and resume.
  Future<bool> check() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    var suspect = false;

    final networkMs = await _platformInt('networkTime');
    if (networkMs != null &&
        (now - networkMs).abs() > _absoluteToleranceMs) {
      suspect = true;
    }

    final mono = await _platformInt('monotonic');
    final state = await _readState();
    if (state != null) {
      final prevMono = state['mono'] as int?;
      if (mono != null && prevMono != null && mono >= prevMono) {
        final monoElapsed = mono - prevMono;
        final wallElapsed = now - (state['wall'] as int);
        if (wallElapsed < monoElapsed - _driftToleranceMs) suspect = true;
      }
      if (now < (state['maxWall'] as int) - _driftToleranceMs) {
        suspect = true;
      }
    }

    final maxWall = state == null
        ? now
        : (now > (state['maxWall'] as int) ? now : state['maxWall'] as int);
    await _writeState({'wall': now, 'mono': mono, 'maxWall': maxWall});

    return suspect;
  }

  Future<int?> _platformInt(String method) async {
    try {
      final value = await _channel.invokeMethod<int>(method);
      return value;
    } catch (_) {
      // No native handler (tests/desktop) or no value available: that
      // signal is simply skipped, the others still apply.
      return null;
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    return _cachedFile ??= File('${dir.path}/$_stateFileName');
  }

  Future<Map<String, dynamic>?> _readState() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return null;
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeState(Map<String, dynamic> state) async {
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(state));
    } catch (_) {
      // Losing a checkpoint only weakens the heuristic; never block the UI.
    }
  }
}
