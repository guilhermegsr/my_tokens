import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyTokens'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search accounts'**
  String get searchHint;

  /// No description provided for @searchCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get searchCancel;

  /// No description provided for @hideTokens.
  ///
  /// In en, this message translates to:
  /// **'Hide codes'**
  String get hideTokens;

  /// No description provided for @showTokens.
  ///
  /// In en, this message translates to:
  /// **'Show codes'**
  String get showTokens;

  /// No description provided for @accountsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No accounts found} =1{1 account found} other{{count} accounts found}}'**
  String accountsFound(int count);

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add an account to start generating verification codes.'**
  String get emptyBody;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'No accounts match your search.'**
  String get emptySearch;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'MyTokens is locked'**
  String get unlockTitle;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to access your codes'**
  String get unlockReason;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @removeAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get removeAccountTitle;

  /// No description provided for @removeAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{account}\"? This account cannot be recovered unless you have a backup.'**
  String removeAccountMessage(String account);

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSave;

  /// No description provided for @actionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get actionDismiss;

  /// No description provided for @clockWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Device clock may be wrong'**
  String get clockWarningTitle;

  /// No description provided for @clockWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Your clock seems to have moved backwards. Verification codes depend on the correct time and may not work until it is fixed.'**
  String get clockWarningBody;

  /// No description provided for @editAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccountTitle;

  /// No description provided for @editAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update how this account is labeled'**
  String get editAccountSubtitle;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'\"{account}\" updated'**
  String accountUpdated(String account);

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'MyTokens'**
  String get drawerTitle;

  /// No description provided for @drawerExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get drawerExport;

  /// No description provided for @drawerExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save an encrypted copy of your accounts'**
  String get drawerExportSubtitle;

  /// No description provided for @drawerImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get drawerImport;

  /// No description provided for @drawerImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore accounts from a backup file'**
  String get drawerImportSubtitle;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lock and appearance'**
  String get drawerSettingsSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require biometrics or device unlock to open MyTokens'**
  String get settingsAppLockSubtitle;

  /// No description provided for @settingsAutoLock.
  ///
  /// In en, this message translates to:
  /// **'Lock when app leaves'**
  String get settingsAutoLock;

  /// No description provided for @settingsLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsLockImmediately;

  /// No description provided for @settingsLockAfter30s.
  ///
  /// In en, this message translates to:
  /// **'After 30 seconds'**
  String get settingsLockAfter30s;

  /// No description provided for @settingsLockAfter1m.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get settingsLockAfter1m;

  /// No description provided for @settingsLockAfter5m.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get settingsLockAfter5m;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'MyTokens · v{version}'**
  String appVersionLabel(String version);

  /// No description provided for @addScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get addScanTitle;

  /// No description provided for @addScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the QR code provided by the service'**
  String get addScanSubtitle;

  /// No description provided for @addManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get addManualTitle;

  /// No description provided for @addManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the setup key by hand'**
  String get addManualSubtitle;

  /// No description provided for @accountAdded.
  ///
  /// In en, this message translates to:
  /// **'\"{account}\" was added'**
  String accountAdded(String account);

  /// No description provided for @accountDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This account is already in MyTokens.'**
  String get accountDuplicate;

  /// No description provided for @scanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Align the QR code within the frame'**
  String get scanInstruction;

  /// No description provided for @fieldIssuer.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get fieldIssuer;

  /// No description provided for @fieldIssuerHint.
  ///
  /// In en, this message translates to:
  /// **'Google, GitHub…'**
  String get fieldIssuerHint;

  /// No description provided for @fieldAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get fieldAccount;

  /// No description provided for @fieldAccountHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get fieldAccountHint;

  /// No description provided for @fieldAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get fieldAccountRequired;

  /// No description provided for @fieldSecret.
  ///
  /// In en, this message translates to:
  /// **'Setup key'**
  String get fieldSecret;

  /// No description provided for @fieldSecretHint.
  ///
  /// In en, this message translates to:
  /// **'JBSWY3DPEHPK3PXP'**
  String get fieldSecretHint;

  /// No description provided for @fieldSecretRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the setup key'**
  String get fieldSecretRequired;

  /// No description provided for @fieldSecretInvalid.
  ///
  /// In en, this message translates to:
  /// **'This setup key is not valid'**
  String get fieldSecretInvalid;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get advancedOptions;

  /// No description provided for @fieldDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get fieldDigits;

  /// No description provided for @fieldPeriod.
  ///
  /// In en, this message translates to:
  /// **'Interval (s)'**
  String get fieldPeriod;

  /// No description provided for @fieldAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get fieldAlgorithm;

  /// No description provided for @addAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccountButton;

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'MyTokens backup'**
  String get backupShareSubject;

  /// No description provided for @backupNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'There are no accounts to back up.'**
  String get backupNoAccounts;

  /// No description provided for @backupNotMyTokens.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid MyTokens backup.'**
  String get backupNotMyTokens;

  /// No description provided for @backupWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password, or the backup has been altered.'**
  String get backupWrongPassword;

  /// No description provided for @backupCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The selected file is invalid or corrupted.'**
  String get backupCorrupted;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the operation. Please try again.'**
  String get backupFailed;

  /// No description provided for @backupWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get backupWorking;

  /// No description provided for @backupImported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No new accounts to import.} =1{1 account imported successfully.} other{{count} accounts imported successfully.}}'**
  String backupImported(int count);

  /// No description provided for @backupPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup password'**
  String get backupPasswordTitle;

  /// No description provided for @backupPasswordSetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a password to protect this backup. Without it, the backup cannot be restored.'**
  String get backupPasswordSetHint;

  /// No description provided for @backupPasswordEnterHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the password used when this backup was created.'**
  String get backupPasswordEnterHint;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldPasswordConfirm;

  /// No description provided for @fieldPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get fieldPasswordTooShort;

  /// No description provided for @fieldPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get fieldPasswordMismatch;

  /// No description provided for @importConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Some accounts already exist'**
  String get importConflictTitle;

  /// No description provided for @importConflictQuestion.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account in this backup is already on this device. Replace it with the backup version, or keep the one you have?} other{{count} accounts in this backup are already on this device. Replace them with the backup versions, or keep the ones you have?}}'**
  String importConflictQuestion(int count);

  /// No description provided for @importReplaceWithBackup.
  ///
  /// In en, this message translates to:
  /// **'Use backup'**
  String get importReplaceWithBackup;

  /// No description provided for @importKeepExisting.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get importKeepExisting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
