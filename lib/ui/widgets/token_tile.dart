import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/account.dart';
import '../account_store.dart';
import '../app_theme.dart';
import 'countdown_ring.dart';

/// How long a copied code is allowed to live in the clipboard before it is
/// wiped. Codes are short-lived secrets; leaving them in the clipboard
/// indefinitely lets any other app read them long after they were needed.
const _clipboardClearDelay = Duration(seconds: 30);

/// One row of the account list: account name, large code and countdown
/// ring. Tap copies the code to the clipboard (auto-cleared shortly after).
/// Since the global press ripple is disabled, the row provides its own
/// press effect — a brief shrink + tinted background — so a tap visibly
/// registers.
class TokenTile extends StatefulWidget {
  const TokenTile({
    super.key,
    required this.account,
    required this.code,
    required this.secondsRemaining,
    this.hidden = false,
  });

  final Account account;
  final String code;
  final int secondsRemaining;

  /// When true the digits are masked behind bullets; tapping still copies
  /// the real code so "hidden" is a shoulder-surfing guard, not a lock.
  final bool hidden;

  @override
  State<TokenTile> createState() => _TokenTileState();
}

/// A fast tap can release before the press animation is even perceptible,
/// so once shown the pressed state is held at least this long.
const _minPressVisible = Duration(milliseconds: 160);

class _TokenTileState extends State<TokenTile> {
  bool _pressed = false;
  DateTime? _pressedAt;

  void _press() {
    _pressedAt = DateTime.now();
    if (mounted && !_pressed) setState(() => _pressed = true);
  }

  /// Releases the pressed state, but never before [_minPressVisible] has
  /// elapsed since the press started — otherwise an instant tap would flip
  /// it off before the effect is seen.
  void _release() {
    final shown = _pressedAt == null
        ? Duration.zero
        : DateTime.now().difference(_pressedAt!);
    final remaining = _minPressVisible - shown;
    if (remaining <= Duration.zero) {
      if (mounted && _pressed) setState(() => _pressed = false);
      return;
    }
    Future<void>.delayed(remaining, () {
      if (mounted && _pressed) setState(() => _pressed = false);
    });
  }

  Future<void> _handleTap() async {
    await HapticFeedback.selectionClick();
    final value = widget.code.replaceAll(' ', '');
    await Clipboard.setData(ClipboardData(text: value));
    _scheduleClipboardClear(value);
  }

  /// Clears the clipboard after [_clipboardClearDelay], but only if it
  /// still holds the code we copied — we must not wipe whatever the user
  /// has copied since.
  void _scheduleClipboardClear(String value) {
    Future<void>.delayed(_clipboardClearDelay, () async {
      final current = await Clipboard.getData(Clipboard.kTextPlain);
      if (current?.text == value) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _pressed
              ? palette.ring.withValues(alpha: 0.12)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 13, color: palette.subtitle),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.hidden
                          ? formatOtpCode('•' * widget.code.length)
                          : formatOtpCode(widget.code),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: palette.title,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CountdownRing(
                secondsRemaining: widget.secondsRemaining,
                period: widget.account.period,
                color: palette.ring,
                labelColor: palette.subtitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
