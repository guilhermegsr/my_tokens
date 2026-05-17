import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/totp/totp_generator.dart';
import '../../data/account.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';
import 'add_account_flow.dart';

/// Manual enrollment form: issuer, account, secret and advanced options.
/// The base32 secret is validated before an [Account] is returned.
class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  State<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends State<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _issuerController = TextEditingController();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();

  int _digits = 6;
  int _period = 30;
  TotpAlgorithm _algorithm = TotpAlgorithm.sha1;
  bool _showAdvanced = false;
  bool _steam = false;

  @override
  void dispose() {
    _issuerController.dispose();
    _labelController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final issuer = _issuerController.text.trim();
    final label = _labelController.text.trim();

    if (_steam) {
      // The Steam shared_secret is base64; store it as base32 so the rest
      // of the app (generation, dedup, backup) stays on one encoding.
      final bytes = base64.decode(
        base64.normalize(_secretController.text.trim()),
      );
      Navigator.of(context).pop(
        Account(
          id: AddAccountFlow.newAccountId(),
          issuer: issuer.isEmpty ? 'Steam' : issuer,
          label: label,
          secret: base32Encode(bytes),
          period: 30,
          algorithm: TotpAlgorithm.sha1,
          kind: AccountKind.steam,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      Account(
        id: AddAccountFlow.newAccountId(),
        issuer: issuer,
        label: label,
        secret: _secretController.text.replaceAll(' ', '').toUpperCase(),
        digits: _digits,
        period: _period,
        algorithm: _algorithm,
      ),
    );
  }

  String? _validateSecret(String? value) {
    final l10n = AppLocalizations.of(context);
    final secret = (value ?? '').trim();
    if (secret.isEmpty) return l10n.fieldSecretRequired;
    if (_steam) {
      try {
        // Steam's shared_secret decodes to a 20-byte HMAC-SHA1 key.
        final bytes = base64.decode(base64.normalize(secret));
        return bytes.length == 20 ? null : l10n.fieldSteamSecretInvalid;
      } on FormatException {
        return l10n.fieldSteamSecretInvalid;
      }
    }
    try {
      // Round-trip through the generator: cheapest correct base32 check.
      const TotpGenerator().generate(secret);
      return null;
    } on FormatException {
      return l10n.fieldSecretInvalid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addManualTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.steamAccount),
              subtitle: Text(l10n.steamAccountHint),
              value: _steam,
              onChanged: (v) => setState(() => _steam = v),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _issuerController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.fieldIssuer,
                hintText: l10n.fieldIssuerHint,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l10n.fieldAccount,
                hintText: l10n.fieldAccountHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.fieldAccountRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secretController,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: _steam ? l10n.fieldSteamSecret : l10n.fieldSecret,
                hintText:
                    _steam ? l10n.fieldSteamSecretHint : l10n.fieldSecretHint,
              ),
              validator: _validateSecret,
            ),
            const SizedBox(height: 16),
            // Steam fixes SHA1 / 30s / 5-char output, so the advanced
            // TOTP parameters don't apply.
            if (!_steam) ...[
              _AdvancedHeader(
                label: l10n.advancedOptions,
                expanded: _showAdvanced,
                onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _showAdvanced
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _digits,
                              decoration: InputDecoration(
                                labelText: l10n.fieldDigits,
                              ),
                              items: const [
                                DropdownMenuItem(value: 6, child: Text('6')),
                                DropdownMenuItem(value: 8, child: Text('8')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _digits = v ?? 6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _period,
                              decoration: InputDecoration(
                                labelText: l10n.fieldPeriod,
                              ),
                              items: const [
                                DropdownMenuItem(value: 30, child: Text('30')),
                                DropdownMenuItem(value: 60, child: Text('60')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _period = v ?? 30),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TotpAlgorithm>(
                        initialValue: _algorithm,
                        decoration: InputDecoration(
                          labelText: l10n.fieldAlgorithm,
                        ),
                        items: TotpAlgorithm.values
                            .map(
                              (a) => DropdownMenuItem(
                                value: a,
                                child: Text(totpAlgorithmName(a)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(
                            () => _algorithm = v ?? TotpAlgorithm.sha1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(l10n.addAccountButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable disclosure header that expands the advanced TOTP parameters,
/// which most users never need to touch.
class _AdvancedHeader extends StatelessWidget {
  const _AdvancedHeader({
    required this.label,
    required this.expanded,
    required this.onTap,
  });

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(Icons.tune, size: 20, color: palette.ring),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.title,
                ),
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(Icons.expand_more, color: palette.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}
