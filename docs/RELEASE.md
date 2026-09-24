# Release

## Versioning

`pubspec.yaml` carries `version: 1.0.0+1` (SemVer + build number). Bump per
release; the version flows into `versionCode`/`versionName` automatically.
The mock API is versioned by URL path (`/v1`).

## Verified builds (this repository, this machine, 2026-09-24)

| Artifact | Command | Result |
| --- | --- | --- |
| Release APK | `flutter build apk --release --target-platform android-arm64` | ✅ `build/app/outputs/flutter-apk/app-release.apk` — **19.9 MB** |
| Release AAB | `flutter build appbundle --release --target-platform android-arm64` | ✅ `build/app/outputs/bundle/release/app-release.aab` — **19.7 MB** |

Honest qualifiers for both:

- **arm64-only** (`--target-platform android-arm64`): the build sandbox
  has ~10 GB of disk, which the NDK + a 3-ABI universal fat APK exhausted.
  arm64-v8a covers virtually all Android devices in circulation today; a
  universal or `--split-per-abi` build needs no code change — only disk.
- **Debug-signed**: no upload keystore exists in this environment
  (fabricating one to claim "production signing configured" would be
  dishonest). The APK installs on devices for review; it is not
  store-ready until signed with upload keys.

Toolchain the builds ran on (installed and configured in this sandbox):

- Flutter 3.47.5 stable, Dart 3.13.4
- Android SDK 36 (platform-tools 37.0.1, build-tools 36.0.0)
- NDK 28.2.13676358 (r28c) — required by the transitive `jni` package
  (`path_provider_android` → `jni`), which compiles real native code
- JDK 17 (Temurin) — the sandbox only shipped a JRE; Gradle needs `javac`
- Gradle 9.3.1 (`-bin` distribution)

Build adjustments made (all committed):

- `android/gradle.properties`: heap tuned from the template's `-Xmx8G`
  (the sandbox has 4 GB RAM — the daemon was OOM-killed) to
  `-Xmx2048m`, `workers.max=2`, daemon disabled.

## Android signing concepts (not performed — no upload key exists)

1. Generate a keystore once (never commit it):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Reference it from `android/key.properties` (git-ignored) and wire it
   in `android/app/build.gradle.kts` via the standard `signingConfigs`
   block (Flutter's "Signing the app" guide).
3. Or use **Play App Signing**: upload key with Google managing the app
   signing key.

`.gitignore` excludes `key.properties`, `*.jks`, `*.keystore`.

## Google Play flow (conceptual, not performed)

1. `flutter build appbundle` (done — Play requires AAB).
2. Create the app in Play Console; upload the AAB to an internal-testing
   track.
3. Set up Play App Signing (first upload enables it).
4. Store listing, screenshots, data-safety form; staged rollout
   (internal → closed → open → production).

## iOS — NOT VERIFIED (Linux environment)

Building for iOS requires macOS with Xcode; this project was built on
Linux, so **no iOS build, archive or simulator run has happened**. The
`ios/` runner from the Flutter scaffold is present and untouched. Steps
when macOS is available: `flutter build ipa` after configuring signing in
Xcode (Runner target → Signing & Capabilities), validate with
`xcrun altool --validate-app`, upload via Transporter or
`--upload`, then TestFlight → review → release.

## Release checklist

- [x] `flutter test` green (131)
- [x] `flutter analyze` clean
- [x] `dart format --set-exit-if-changed` clean
- [x] CI workflow present (`.github/workflows/flutter_ci.yml`)
- [x] Release APK builds (arm64, debug-signed — see qualifiers above)
- [x] Release AAB builds (arm64, debug-signed)
- [ ] Universal 3-ABI build (needs a disk roomier than this sandbox)
- [ ] Android production signing (needs an upload keystore)
- [ ] Store listing/screenshots
- [ ] iOS build (requires macOS — not attempted)
- [ ] `--obfuscate --split-debug-info` pass (straightforward to add)

## Runbook: producing a review build

```bash
flutter pub get
flutter build apk --release --target-platform android-arm64
adb install build/app/outputs/flutter-apk/app-release.apk
```

Demo credentials for reviewers: tap **Use demo account** on the login
screen. The Profile tab's **API condition simulator** demonstrates the
error-state UX without infrastructure.
