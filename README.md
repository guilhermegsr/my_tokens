<p align="center">
  <img src="assets/icon/app_icon.png" width="112" alt="MyTokens" />
</p>

<h1 align="center">MyTokens</h1>

<p align="center">An offline, secure TOTP authenticator for Android.</p>

<p align="center">
  <a href="https://github.com/guilhermegsr/my_tokens/actions/workflows/ci.yml">
    <img src="https://github.com/guilhermegsr/my_tokens/actions/workflows/ci.yml/badge.svg" alt="CI" />
  </a>
  <img src="https://img.shields.io/badge/License-MIT-3D52F0" alt="MIT" />
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

A two-factor authenticator that keeps your accounts entirely on your
device. No cloud, no account, no internet permission — your secrets are
encrypted locally and never leave the phone.

## Features

- **Standards-compliant TOTP** — RFC 6238, SHA1/256/512, 6–8 digits,
  custom periods
- **Encrypted at rest** — AES-256-GCM vault with the key sealed in the
  Android Keystore
- **Portable, secure backups** — a single password-protected file you
  control, hardened with Argon2id
- **App lock** — biometric or device credential, with a configurable
  grace period
- **Reliability built in** — duplicate detection and out-of-sync clock
  warnings so codes never fail silently
- **Polished experience** — light/dark themes, English and Portuguese

## Security

- 100% offline — no internet permission, no telemetry, no backend
- Secrets sealed in an AES-256-GCM vault; the key lives in the Android
  Keystore and is never written in cleartext
- Backups encrypted with the user's password via Argon2id
- Screenshots and the app-switcher preview are blocked
- Cloud and device-transfer backups of the vault are disabled

Vulnerability reporting is described in [SECURITY.md](SECURITY.md).

## Download

Get the signed APK from the
**[latest release](https://github.com/guilhermegsr/my_tokens/releases/latest)**.
No store account or setup required.

<sub>Building from source and release signing are documented in
[RELEASE.md](RELEASE.md).</sub>
