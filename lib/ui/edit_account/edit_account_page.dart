import 'package:flutter/material.dart';

import '../../data/account.dart';
import '../../l10n/app_localizations.dart';
import '../app_theme.dart';

/// Edits the human-readable identity of an account (service / account
/// name). The secret and TOTP parameters are intentionally left
/// untouched. Returns the updated [Account] via [Navigator.pop], or
/// nothing if the user backs out.
class EditAccountPage extends StatefulWidget {
  const EditAccountPage({super.key, required this.account});

  final Account account;

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _issuer;
  late final TextEditingController _label;

  @override
  void initState() {
    super.initState();
    _issuer = TextEditingController(text: widget.account.issuer)
      ..addListener(_refreshPreview);
    _label = TextEditingController(text: widget.account.label)
      ..addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _issuer.dispose();
    _label.dispose();
    super.dispose();
  }

  void _refreshPreview() => setState(() {});

  String get _previewName {
    final issuer = _issuer.text.trim();
    final label = _label.text.trim();
    if (issuer.isEmpty) return label;
    return label.isEmpty ? issuer : '$issuer : $label';
  }

  String get _avatarLetter {
    final source = _issuer.text.trim().isNotEmpty
        ? _issuer.text.trim()
        : _label.text.trim();
    return source.isEmpty ? '?' : source.characters.first.toUpperCase();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      widget.account.copyWith(
        issuer: _issuer.text.trim(),
        label: _label.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editAccountTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _PreviewHeader(
              letter: _avatarLetter,
              name: _previewName,
              subtitle: l10n.editAccountSubtitle,
              palette: palette,
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _issuer,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.fieldIssuer,
                hintText: l10n.fieldIssuerHint,
                prefixIcon: const Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _label,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.fieldAccount,
                hintText: l10n.fieldAccountHint,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.fieldAccountRequired
                  : null,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(l10n.actionSave),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({
    required this.letter,
    required this.name,
    required this.subtitle,
    required this.palette,
  });

  final String letter;
  final String name;
  final String subtitle;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: palette.fieldFill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.ring.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: palette.ring,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name.isEmpty ? '—' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: palette.subtitle),
          ),
        ],
      ),
    );
  }
}
