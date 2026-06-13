# MyTokens — Privacy Policy

_Last updated: 2026-06-12_

MyTokens is an offline TOTP (two-factor authentication) app. This policy
explains what the app does and does not do with your data.

## Summary

**MyTokens does not collect, transmit, or share any personal data.**
Everything stays on your device.

## Data we process and where it stays

- **Account secrets and labels** (the issuer, account name, and the shared
  secret used to generate codes) are stored **only on your device**, inside
  an encrypted vault. The encryption key is held in the Android Keystore /
  iOS Keychain and never leaves the device.
- **Encrypted backups** are created **only when you explicitly export one**.
  The backup file is encrypted with a password you choose (Argon2id key
  derivation). You decide where it is saved or shared; the app never uploads
  it anywhere.
- **App settings** (lock options, screen capture preference, theme) are stored
  locally on your device and contain no personal data.

## What we do NOT do

- No accounts, sign-up, or login.
- No analytics, tracking, advertising, or third-party SDKs.
- **No internet access.** The Android app ships without the `INTERNET`
  permission, so it is technically incapable of sending your data anywhere.
- No data is sold or shared with anyone.

## Permissions

- **Camera** — used only to scan setup QR codes when you add an account.
  No images are stored or transmitted.
- **Biometric / device unlock** — used only, and optionally, to lock the
  app. Authentication is handled by the operating system; MyTokens never
  sees your biometric data.

## Data deletion

Removing an account, or uninstalling the app, permanently deletes the
related data from your device. Because nothing is stored off-device, there
is nothing for us to delete on your behalf.

## Children

MyTokens is a general-purpose security utility and is not directed at
children.

## Changes

If this policy changes, the updated version will be published at the same
URL with a new "Last updated" date.

## Contact

Questions: guilherme.gsr.02@gmail.com
