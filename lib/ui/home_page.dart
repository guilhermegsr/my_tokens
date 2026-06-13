import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/time/clock_guard.dart';
import '../data/account.dart';
import '../l10n/app_localizations.dart';
import 'account_store.dart';
import 'add_account/add_account_flow.dart';
import 'app_theme.dart';
import 'backup/backup_flow.dart';
import 'backup_drawer.dart';
import 'edit_account/edit_account_page.dart';
import 'settings/settings_page.dart';
import 'settings/settings_store.dart';
import 'widgets/app_notification.dart';
import 'widgets/search_field.dart';
import 'widgets/token_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _clockSuspect = false;
  bool _clockWarningDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkClock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The clock can be changed while we are backgrounded; re-check on the
    // way back in.
    if (state == AppLifecycleState.resumed) _checkClock();
  }

  Future<void> _checkClock() async {
    final suspect = await ClockGuard.instance.check();
    if (mounted && suspect != _clockSuspect) {
      setState(() => _clockSuspect = suspect);
    }
  }

  void _activateSearch() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _toggleTokensHidden() {
    final settings = context.read<SettingsStore>();
    settings.setTokensHidden(!settings.tokensHidden);
  }

  void _cancelSearch() {
    _searchController.clear();
    context.read<AccountStore>().search('');
    setState(() => _isSearching = false);
  }

  Future<bool> _askRemove(Account account) async {
    final l10n = AppLocalizations.of(context);
    final palette = AppPalette.of(context);
    final danger = Theme.of(context).colorScheme.error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.delete_outline, color: danger, size: 26),
        ),
        title: Text(l10n.removeAccountTitle),
        content: Text(
          l10n.removeAccountMessage(account.displayName),
          textAlign: TextAlign.center,
          style: TextStyle(color: palette.subtitle, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.actionRemove),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _editAccount(AccountStore store, Account account) async {
    final updated = await Navigator.of(context).push<Account>(
      MaterialPageRoute(builder: (_) => EditAccountPage(account: account)),
    );
    if (updated == null || !mounted) return;
    await store.update(updated);
    if (mounted) {
      AppNotification.show(
        context,
        AppLocalizations.of(context).accountUpdated(updated.displayName),
        kind: NotificationKind.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);
    final store = context.watch<AccountStore>();
    final tokensHidden = context.watch<SettingsStore>().tokensHidden;

    // Always alphabetical, case-insensitive so "github" and "GitHub" sort
    // together.
    final accounts = [...store.accounts]..sort(
        (a, b) => a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase()),
      );

    return Scaffold(
      key: _scaffoldKey,
      drawer: BackupDrawer(
        onExport: () => BackupFlow.export(context),
        onImport: () => BackupFlow.import(context),
        onSettings: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddAccountFlow.start(context),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_clockSuspect && !_clockWarningDismissed)
              _ClockWarningBanner(
                onDismiss: () =>
                    setState(() => _clockWarningDismissed = true),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: SearchField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                isActive: _isSearching,
                tokensHidden: tokensHidden,
                onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
                onToggleHidden: _toggleTokensHidden,
                onActivate: _activateSearch,
                onCancel: _cancelSearch,
                onChanged: store.search,
              ),
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.accountsFound(accounts.length),
                    style: TextStyle(fontSize: 13, color: palette.subtitle),
                  ),
                ),
              ),
            Expanded(
              child: store.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : accounts.isEmpty
                      ? _EmptyState(isSearching: store.isSearching)
                      : ListView.separated(
                          padding:
                              const EdgeInsets.only(top: 8, bottom: 96),
                          itemCount: accounts.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            thickness: 1,
                            indent: 24,
                            endIndent: 24,
                            color: palette.divider,
                          ),
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            final totp = store.codeFor(account);
                            return Dismissible(
                              key: ValueKey(account.id),
                              // Swipe right reveals edit; swipe left reveals
                              // delete.
                              background: const _SwipeActionBackground(
                                alignment: Alignment.centerLeft,
                                icon: Icons.edit_outlined,
                                isDestructive: false,
                              ),
                              secondaryBackground:
                                  const _SwipeActionBackground(
                                alignment: Alignment.centerRight,
                                icon: Icons.delete_outline,
                                isDestructive: true,
                              ),
                              confirmDismiss: (direction) async {
                                if (direction ==
                                    DismissDirection.startToEnd) {
                                  await _editAccount(store, account);
                                  return false;
                                }
                                return _askRemove(account);
                              },
                              onDismissed: (_) => store.remove(account),
                              child: TokenTile(
                                account: account,
                                code: totp.code,
                                secondsRemaining: totp.secondsRemaining,
                                hidden: tokensHidden,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isSearching});

  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final l10n = AppLocalizations.of(context);

    if (isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            l10n.emptySearch,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: palette.subtitle),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: palette.title,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.emptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: palette.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the device clock appears to have been moved backwards.
/// Because every TOTP code depends on the wall clock, a wrong clock makes
/// all codes silently fail — surfacing it explains an otherwise baffling
/// "the codes don't work" situation.
class _ClockWarningBanner extends StatelessWidget {
  const _ClockWarningBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final danger = Theme.of(context).colorScheme.error;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.schedule_outlined, color: danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.clockWarningTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.clockWarningBody,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppPalette.of(context).subtitle,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 20),
            color: AppPalette.of(context).subtitle,
            tooltip: l10n.actionDismiss,
          ),
        ],
      ),
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.alignment,
    required this.icon,
    required this.isDestructive,
  });

  final Alignment alignment;
  final IconData icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : AppPalette.of(context).ring;
    return Container(
      color: color.withValues(alpha: 0.14),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Icon(icon, color: color),
    );
  }
}
