# Release

Application ID `net.guilhermegomes.mytokens`. Version is set in
`pubspec.yaml` (`x.y.z+build`); bump the build number every release.

## Signing

Release builds are signed when `android/key.properties` exists,
otherwise the debug key is used (so `flutter run` keeps working).

Generate the upload keystore once and back up the `.jks` and its
passwords — losing them makes signed updates over an installed version
impossible:

```
keytool -genkey -v -keystore ~/mytokens.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties` (git-ignored):

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/mytokens.jks
```

## Build

```
flutter build apk --release
```

Artifact: `build/app/outputs/flutter-apk/app-release.apk`. Building
without the Android NDK emits a harmless strip-symbols warning; the APK
is still produced.

## Publish

Tag the release (`vX.Y.Z`), create a GitHub Release, and attach the
signed APK. Obtainium tracks the repository for automatic updates.
