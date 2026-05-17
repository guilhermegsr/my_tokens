# Building a signed release APK

App ID: `net.guilhermegomes.mytokens`. The version lives in
`pubspec.yaml` (`1.0.0+1`); bump the `+N` build number on each build.

## 1. Create the keystore (once)

Interactive — run it yourself:

```bash
keytool -genkey -v -keystore ~/mytokens.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep the `.jks` and its passwords backed up. Losing them means you can
no longer ship signed updates that install over an existing version.

## 2. Wire the keystore

Create `android/key.properties` (git-ignored) with your real values:

```
storePassword=<store password>
keyPassword=<key password>
keyAlias=upload
storeFile=/absolute/path/to/mytokens.jks
```

The build uses release signing automatically when this file exists, and
debug signing when it doesn't (so `flutter run` keeps working).

## 3. Build

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. Install it on
the device (enable installing from unknown sources).

> Building without the Android NDK prints a harmless "failed to strip
> debug symbols" warning; the APK is still produced.
