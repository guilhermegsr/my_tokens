# MyTokens

An offline, secure TOTP authenticator (RFC 6238). Bilingual UI
(English / Portuguese, follows the device language).

## Features

- TOTP codes (SHA1/256/512, 6–8 digits, custom period).
- Add accounts by QR scan or manual entry; the same account can't be
  added twice.
- Encrypted, password-protected backup (export / import).
- Biometric / device-credential app lock, configurable timeout.
- Light / dark theme.
- Out-of-sync clock warning.

## Security

- **Fully offline** — no internet permission.
- Secrets live only in `vault.enc`, encrypted with **AES-256-GCM**. The
  key is stored in the Android Keystore / iOS Keychain, never in
  cleartext.
- Backups are encrypted with a password via **Argon2id**.
- `FLAG_SECURE` blocks screenshots and the app-switcher preview.
- The vault is written atomically (temp file + rename).

## Build & run

```bash
flutter pub get
flutter test       # incl. official RFC 6238 vectors
flutter analyze
flutter run
```

To change UI strings, edit `lib/l10n/app_en.arb` and `app_pt.arb`, then
`flutter gen-l10n`.

## Install / distribute

No app store needed. Distribute the signed APK via **GitHub Releases**:

```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

Attach that `.apk` to a GitHub Release. Users enable "install from
unknown sources" and install it directly; apps like Obtainium can then
auto-update straight from the repository. Signing setup is in
`RELEASE.md`.
