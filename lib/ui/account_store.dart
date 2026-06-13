import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/totp/totp_generator.dart';
import '../data/account.dart';
import '../data/account_repository.dart';

class AccountStore extends ChangeNotifier {
  AccountStore(this._repository) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  final AccountRepository _repository;
  final TotpGenerator _totp = const TotpGenerator();

  late final Timer _ticker;
  List<Account> _accounts = [];
  String _searchQuery = '';
  bool _isLoading = true;
  Future<void> _saveQueue = Future.value();

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<Account> get accounts {
    if (_searchQuery.isEmpty) return List.unmodifiable(_accounts);
    final query = _searchQuery.toLowerCase();
    return _accounts
        .where(
          (a) =>
              a.issuer.toLowerCase().contains(query) ||
              a.label.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> load() async {
    try {
      _accounts = await _repository.load();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  TotpCode codeFor(Account account) => _totp.generate(
    account.secret,
    digits: account.digits,
    period: account.period,
    algorithm: account.algorithm,
  );

  /// Adds [account] unless one with the same secret already exists.
  /// Returns false when it's a duplicate (nothing is changed).
  Future<bool> add(Account account) async {
    if (_accounts.any((a) => a.identity == account.identity)) return false;
    _accounts = [..._accounts, account];
    notifyListeners();
    await _saveAccounts(_accounts);
    return true;
  }

  Future<void> remove(Account account) async {
    _accounts = _accounts.where((a) => a.id != account.id).toList();
    notifyListeners();
    await _saveAccounts(_accounts);
  }

  Future<void> update(Account account) async {
    _accounts = [for (final a in _accounts) a.id == account.id ? account : a];
    notifyListeners();
    await _saveAccounts(_accounts);
  }

  Future<void> replaceAll(List<Account> accounts) async {
    _accounts = List<Account>.from(accounts);
    notifyListeners();
    await _saveAccounts(_accounts);
  }

  Future<void> _saveAccounts(List<Account> accounts) {
    final snapshot = List<Account>.from(accounts);
    _saveQueue = _saveQueue.then(
      (_) => _repository.save(snapshot),
      onError: (_) => _repository.save(snapshot),
    );
    return _saveQueue;
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }
}

/// Splits a code into two readable groups: "428913" -> "428 913".
String formatOtpCode(String code) {
  if (code.length <= 4) return code;
  final mid = (code.length / 2).ceil();
  return '${code.substring(0, mid)} ${code.substring(mid)}';
}
