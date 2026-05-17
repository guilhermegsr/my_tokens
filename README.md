<p align="center">
  <img src="assets/icon/app_icon.png" width="112" alt="MyTokens" />
</p>

<h1 align="center">MyTokens</h1>

<p align="center">
  A simple, offline and secure two-factor authentication app for Android.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/100%25-Offline-1FAD6B" alt="Offline" />
  <img src="https://img.shields.io/badge/Vault-AES--256--GCM-3D52F0" alt="AES-256-GCM" />
</p>

<p align="center">
  <a href="https://github.com/guilhermegsr/my_tokens/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-3D52F0?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" />
  </a>
</p>

---

## About

**MyTokens** generates the 6–8 digit verification codes (TOTP, RFC 6238)
for your two-factor accounts — the same kind of codes other authenticator
apps produce. It runs **completely offline** and keeps every secret
encrypted on your device. Nothing ever leaves your phone.

## ✨ Features

- 🔢 TOTP codes (SHA1/256/512, 6–8 digits, custom period)
- 📷 Add accounts by QR scan or manual entry
- 🚫 The same account can't be added twice
- 🗄️ Encrypted, password-protected backup (export / import)
- 👆 Biometric / device lock with configurable timeout
- 🌗 Light & dark theme
- 🕒 Out-of-sync clock warning
- 🌎 English & Portuguese (follows the device language)

## 🔒 Security

- **No internet permission** — minimal attack surface, nothing is sent anywhere
- Secrets live only in an **AES-256-GCM** vault; the key is kept in the
  Android Keystore, never in cleartext
- Backups are encrypted with your password via **Argon2id**
- Screenshots and the app-switcher preview are blocked

## ⬇️ Download

Get the latest signed APK from the
[**Releases**](https://github.com/guilhermegsr/my_tokens/releases/latest)
page:

1. Download `app-release.apk`.
2. Allow installing from unknown sources when prompted.
3. Open the app and add your accounts.

> Tip: [Obtainium](https://github.com/ImranR98/Obtainium) can track this
> repository and update MyTokens automatically on new releases.
