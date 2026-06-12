<p align="center">
  <img src="assets/icon/app_icon.png" width="112" alt="MyTokens app icon" />
</p>

<h1 align="center">MyTokens</h1>

<p align="center">
  <strong>Private 2FA for Android. No cloud. No account. No internet permission.</strong>
</p>

<p align="center">
  MyTokens is an offline two-factor authenticator for Android that keeps your
  verification codes encrypted on your device and ready when you need them.
</p>

<p align="center">
  <strong>English</strong> · <a href="README.pt-BR.md">Português</a>
</p>

<p align="center">
  <a href="https://github.com/guilhermegsr/my_tokens/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-3D52F0?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/guilhermegsr/my_tokens/actions/workflows/ci.yml">
    <img src="https://github.com/guilhermegsr/my_tokens/actions/workflows/ci.yml/badge.svg" alt="CI status" />
  </a>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter&logoColor=white" alt="Built with Flutter" />
  <img src="https://img.shields.io/badge/Offline-100%25-1FAD6B" alt="100% offline" />
  <img src="https://img.shields.io/badge/Vault-AES--256--GCM-3D52F0" alt="AES-256-GCM vault" />
  <img src="https://img.shields.io/badge/License-MIT-3D52F0" alt="MIT license" />
</p>

---

## Why MyTokens

Most authenticators make a tradeoff between convenience and control. MyTokens
is built for people who want a polished daily authenticator without sending
their secrets to a service they do not control.

| Private by default | Built for real use | Secure when it matters |
| --- | --- | --- |
| No accounts, telemetry, backend, cloud sync, or internet permission. | Fast search, code hiding, QR enrollment, encrypted backups, and light/dark themes. | AES-256-GCM vault, Android Keystore protection, app lock, and screenshot blocking by default. |

## Product Tour

<table>
  <tr>
    <td align="center" width="50%">
      <img src="assets/screenshots/home-visible-code.png" width="280" alt="Home screen showing a visible verification code" />
      <br />
      <strong>Codes at a glance</strong>
      <br />
      <sub>Search accounts quickly, view the current code, and follow the remaining lifetime with a clear countdown.</sub>
    </td>
    <td align="center" width="50%">
      <img src="assets/screenshots/home-hidden-code.png" width="280" alt="Home screen with verification codes hidden" />
      <br />
      <strong>Hide codes instantly</strong>
      <br />
      <sub>Mask tokens when you are around other people, recording a demo, or sharing your screen.</sub>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <img src="assets/screenshots/navigation-drawer.png" width="280" alt="Navigation drawer with export, import, and settings" />
      <br />
      <strong>Backup and restore</strong>
      <br />
      <sub>Export a password-protected backup and restore it later without depending on a cloud account.</sub>
    </td>
    <td align="center" width="50%">
      <img src="assets/screenshots/settings-security.png" width="280" alt="Settings screen with app lock and screen capture controls" />
      <br />
      <strong>Security controls</strong>
      <br />
      <sub>Choose app lock behavior and explicitly allow screenshots, recordings, or screen sharing only when needed.</sub>
    </td>
  </tr>
</table>

<p align="center"><sub>Screenshots use demo data. Screen capture is blocked by default.</sub></p>

## Highlights

- **100% offline operation** - no network permission, no server dependency,
  and no hidden sync layer.
- **Standards-compliant TOTP** - RFC 6238 support with SHA-1, SHA-256,
  SHA-512, 6-8 digits, and custom periods.
- **Encrypted local vault** - account labels and secrets are encrypted at rest
  with AES-256-GCM.
- **Hardware-backed key protection** - the vault key is generated locally and
  sealed by the Android Keystore.
- **Secure portable backups** - exports are encrypted with your password and
  hardened with Argon2id.
- **Optional app lock** - require biometrics or device credentials, with a
  configurable grace period.
- **Screen privacy controls** - screenshots, recordings, screen sharing, and
  app-switcher previews are blocked by default, with manual opt-in.
- **Everyday polish** - code hiding, duplicate detection, clock warnings,
  responsive UI, dark/light themes, and English/Portuguese localization.

## Security Model

MyTokens is designed around a simple principle: authentication secrets should
not leave the device unless the user intentionally exports an encrypted backup.

- MyTokens does not request the Android `INTERNET` permission.
- Account secrets are stored only in the local encrypted vault.
- The vault key is generated on-device and protected by the Android Keystore.
- Backups are encrypted before leaving the app, using a password chosen by the
  user.
- Security-sensitive settings are stored in OS-backed secure storage.
- Cloud and device-transfer backups of the vault are disabled on Android.
- Screenshots and screen sharing are blocked unless explicitly enabled in
  settings.

For vulnerability reporting, see [SECURITY.md](SECURITY.md).

## Install

Download the signed APK from the
**[latest release](https://github.com/guilhermegsr/my_tokens/releases/latest)**.
No store account, cloud setup, or internet access is required.

## Build From Source

Requirements:

- Flutter stable
- Android SDK with accepted licenses
- JDK compatible with the Android Gradle plugin

Common development commands:

```bash
flutter pub get
flutter test
flutter build apk --debug
```

Release signing and distribution notes are documented in
[RELEASE.md](RELEASE.md).

## Privacy

MyTokens is designed so your authentication data never leaves your device. The
full privacy policy is available in [PRIVACY.md](PRIVACY.md).

## License

MyTokens is released under the [MIT License](LICENSE).
