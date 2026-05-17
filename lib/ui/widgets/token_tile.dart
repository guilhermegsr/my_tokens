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
/// The OS already shows its own "copied" confirmation, so the app stays
/// quiet.
class TokenTile extends StatelessWidget {
  const TokenTile({
    super.key,
    required this.account,
    required this.code,
    required this.secondsRemaining,
  });

  final Account account;
  final String code;
  final int secondsRemaining;

  Future<void> _copyToClipboard() async {
    final value = code.replaceAll(' ', '');
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

    return InkWell(
      onTap: _copyToClipboard,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: palette.subtitle),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatOtpCode(code),
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
              secondsRemaining: secondsRemaining,
              period: account.period,
              color: palette.ring,
              labelColor: palette.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
