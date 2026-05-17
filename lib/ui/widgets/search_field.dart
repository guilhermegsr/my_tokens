import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../app_theme.dart';

/// Search pill: menu icon + hint at rest; a text field with clear and
/// cancel once active.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.tokensHidden,
    required this.onOpenMenu,
    required this.onToggleHidden,
    required this.onActivate,
    required this.onCancel,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final bool tokensHidden;
  final VoidCallback onOpenMenu;
  final VoidCallback onToggleHidden;
  final VoidCallback onActivate;
  final VoidCallback onCancel;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);

    final pill = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: palette.fieldFill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          if (!isActive) ...[
            InkResponse(
              onTap: onOpenMenu,
              child: Icon(Icons.menu, size: 22, color: palette.title),
            ),
            const SizedBox(width: 12),
            Container(width: 1, height: 22, color: palette.divider),
            const SizedBox(width: 12),
          ],
          Icon(Icons.search, size: 22, color: palette.subtitle),
          const SizedBox(width: 10),
          Expanded(
            child: isActive
                ? TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(fontSize: 16, color: palette.title),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: l10n.searchHint,
                      hintStyle:
                          TextStyle(fontSize: 16, color: palette.subtitle),
                    ),
                  )
                : GestureDetector(
                    onTap: onActivate,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      l10n.searchHint,
                      style: TextStyle(fontSize: 16, color: palette.subtitle),
                    ),
                  ),
          ),
          if (isActive && controller.text.isNotEmpty)
            InkResponse(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Icon(Icons.cancel, size: 20, color: palette.subtitle),
            ),
          if (!isActive) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 22, color: palette.divider),
            const SizedBox(width: 12),
            Tooltip(
              message: tokensHidden ? l10n.showTokens : l10n.hideTokens,
              child: InkResponse(
                onTap: onToggleHidden,
                child: Icon(
                  tokensHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 22,
                  color: palette.title,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!isActive) return pill;
    return Row(
      children: [
        Expanded(child: pill),
        TextButton(
          onPressed: onCancel,
          child: Text(l10n.searchCancel),
        ),
      ],
    );
  }
}
