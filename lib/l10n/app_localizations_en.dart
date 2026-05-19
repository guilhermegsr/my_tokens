// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyTokens';

  @override
  String get searchHint => 'Search accounts';

  @override
  String get searchCancel => 'Cancel';

  @override
  String get hideTokens => 'Hide codes';

  @override
  String get showTokens => 'Show codes';

  @override
  String accountsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts found',
      one: '1 account found',
      zero: 'No accounts found',
    );
    return '$_temp0';
  }

  @override
  String get emptyTitle => 'No accounts yet';

  @override
  String get emptyBody =>
      'Add an account to start generating verification codes.';

  @override
  String get emptySearch => 'No accounts match your search.';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get unlockTitle => 'MyTokens is locked';

  @override
  String get unlockReason => 'Verify your identity to access your codes';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get removeAccountTitle => 'Remove account';

  @override
  String removeAccountMessage(String account) {
    return 'Remove \"$account\"? This account cannot be recovered unless you have a backup.';
  }

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionSave => 'Save changes';

  @override
  String get actionDismiss => 'Dismiss';

  @override
  String get clockWarningTitle => 'Device clock may be wrong';

  @override
  String get clockWarningBody =>
      'Your clock seems to have moved backwards. Verification codes depend on the correct time and may not work until it is fixed.';

  @override
  String get editAccountTitle => 'Edit account';

  @override
  String get editAccountSubtitle => 'Update how this account is labeled';

  @override
  String accountUpdated(String account) {
    return '\"$account\" updated';
  }

  @override
  String get drawerTitle => 'MyTokens';

  @override
  String get drawerExport => 'Export';

  @override
  String get drawerExportSubtitle => 'Save an encrypted copy of your accounts';

  @override
  String get drawerImport => 'Import';

  @override
  String get drawerImportSubtitle => 'Restore accounts from a backup file';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerSettingsSubtitle => 'Lock and appearance';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockSubtitle =>
      'Require biometrics or device unlock to open MyTokens';

  @override
  String get settingsAutoLock => 'Lock when app leaves';

  @override
  String get settingsLockImmediately => 'Immediately';

  @override
  String get settingsLockAfter30s => 'After 30 seconds';

  @override
  String get settingsLockAfter1m => 'After 1 minute';

  @override
  String get settingsLockAfter5m => 'After 5 minutes';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String appVersionLabel(String version) {
    return 'MyTokens · v$version';
  }

  @override
  String get addScanTitle => 'Scan QR code';

  @override
  String get addScanSubtitle => 'Use the QR code provided by the service';

  @override
  String get addManualTitle => 'Enter manually';

  @override
  String get addManualSubtitle => 'Enter the setup key by hand';

  @override
  String accountAdded(String account) {
    return '\"$account\" was added';
  }

  @override
  String get accountDuplicate => 'This account is already in MyTokens.';

  @override
  String get scanInstruction => 'Align the QR code within the frame';

  @override
  String get fieldIssuer => 'Service';

  @override
  String get fieldIssuerHint => 'Google, GitHub…';

  @override
  String get fieldAccount => 'Account';

  @override
  String get fieldAccountHint => 'you@email.com';

  @override
  String get fieldAccountRequired => 'Please enter an account name';

  @override
  String get fieldSecret => 'Setup key';

  @override
  String get fieldSecretHint => 'JBSWY3DPEHPK3PXP';

  @override
  String get fieldSecretRequired => 'Please enter the setup key';

  @override
  String get fieldSecretInvalid => 'This setup key is not valid';

  @override
  String get advancedOptions => 'Advanced options';

  @override
  String get fieldDigits => 'Digits';

  @override
  String get fieldPeriod => 'Interval (s)';

  @override
  String get fieldAlgorithm => 'Algorithm';

  @override
  String get addAccountButton => 'Add account';

  @override
  String get backupShareSubject => 'MyTokens backup';

  @override
  String get backupNoAccounts => 'There are no accounts to back up.';

  @override
  String get backupNotMyTokens => 'This file is not a valid MyTokens backup.';

  @override
  String get backupWrongPassword =>
      'Incorrect password, or the backup has been altered.';

  @override
  String get backupCorrupted => 'The selected file is invalid or corrupted.';

  @override
  String get backupFailed =>
      'Could not complete the operation. Please try again.';

  @override
  String get backupWorking => 'Working…';

  @override
  String backupImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts imported successfully.',
      one: '1 account imported successfully.',
      zero: 'No new accounts to import.',
    );
    return '$_temp0';
  }

  @override
  String get backupPasswordTitle => 'Backup password';

  @override
  String get backupPasswordSetHint =>
      'Choose a password to protect this backup. Without it, the backup cannot be restored.';

  @override
  String get backupPasswordEnterHint =>
      'Enter the password used when this backup was created.';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Confirm password';

  @override
  String get fieldPasswordTooShort => 'Use at least 12 characters';

  @override
  String get fieldPasswordMismatch => 'The passwords do not match';

  @override
  String get importConflictTitle => 'Some accounts already exist';

  @override
  String importConflictQuestion(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count accounts in this backup are already on this device. Replace them with the backup versions, or keep the ones you have?',
      one:
          '1 account in this backup is already on this device. Replace it with the backup version, or keep the one you have?',
    );
    return '$_temp0';
  }

  @override
  String get importReplaceWithBackup => 'Use backup';

  @override
  String get importKeepExisting => 'Keep mine';
}
