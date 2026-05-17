# Releasing MyTokens to Google Play

App ID: `net.guilhermegomes.mytokens` · Version: see `pubspec.yaml`
(`1.0.0+1`). Bump the `+N` build number on every upload.

## 1. Create the upload keystore (once)

Run this yourself (interactive — it asks for passwords):

```
keytool -genkey -v -keystore ~/mytokens-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep the `.jks` and its passwords safe and backed up. Losing them means
you can no longer update the app.

## 2. Wire the keystore

Copy `android/key.properties.example` to `android/key.properties` and fill
in the real values (`storeFile` = absolute path to the `.jks`).

`key.properties` and `*.jks` are git-ignored. The Gradle build uses the
release signing config automatically when `key.properties` exists, and
falls back to debug signing when it doesn't (so plain `flutter run` keeps
working).

## 3. Build the App Bundle

```
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Upload this
`.aab` (not an APK) to the Play Console.

> Note: building inside this dev sandbox prints "failed to strip debug
> symbols" because the Android NDK isn't installed here. On a normal
> machine with the NDK the symbols are stripped and the bundle is much
> smaller. It is not a code problem.

## 4. Play Console — done outside this repo

These are manual and cannot be automated from code:

- [ ] Developer account ($25, one-time).
- [ ] **Privacy policy URL** — host `PRIVACY.md` (e.g.
      `https://guilhermegomes.net/mytokens/privacy`) and paste the URL.
- [ ] **Data safety form** — declare: no data collected, no data shared,
      app works offline (matches `PRIVACY.md`).
- [ ] Store listing: title, short & full description, app icon 512×512,
      feature graphic 1024×500, phone screenshots.
- [ ] Content rating questionnaire.
- [ ] Target audience & content.
- [ ] For new personal accounts: closed test with 12 testers for 14 days
      before production access.

## Already handled in the codebase

- Unique application ID (`net.guilhermegomes.mytokens`), package + Kotlin
  namespace renamed.
- Release signing config (keystore-driven, with safe debug fallback).
- Branded adaptive launcher icon (indigo shield, app accent `#3D52F0`).
- Version set to `1.0.0+1`.
- Offline guarantees: no `INTERNET` permission; `FLAG_SECURE` blocks
  screenshots/recents; vault AES-256-GCM with key in Keystore/Keychain.
