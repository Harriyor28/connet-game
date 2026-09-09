# Nexus Link Release Readiness

Prepared version: `1.0.0+1`

Codemagic workflow: [codemagic.yaml](../codemagic.yaml)

## Build environments

Use an explicit Dart define for every build:

```powershell
flutter build apk --debug --dart-define=NEXUS_LINK_ENV=development
flutter build appbundle --release --dart-define=NEXUS_LINK_ENV=production
```

Codemagic uses the same `NEXUS_LINK_ENV` define. The M2 machine identifier in
the workflow is `mac_mini_m2`; verify that this identifier is available in the
Codemagic account before enabling the workflows.

Supported values are `development`, `staging`, and `production`. Unknown or omitted values default to development.

Development uses official Google test ad units and local development diagnostics. Production uses blank AdMob placeholders until real IDs are supplied and requires granted analytics consent.

## Release blockers

- Production Android AdMob app and unit IDs are not supplied.
- Production iOS AdMob app ID is not supplied.
- Android and iOS native AdMob configuration still contains Google's official
    test app ID; replace it only after production IDs are supplied.
- Android release signing keystore, alias, and private credentials are not configured.
- The local Android NDK installation is malformed and lacks `source.properties`.
- No Android device or emulator is currently available for install/smoke testing.
- iOS release builds require macOS, Xcode, CocoaPods, and Apple signing credentials.
- No privacy policy URL, support URL, developer identity, store category, age rating, or legal review has been supplied.
- Final production app icons and store screenshots require product-owner confirmation.
- The current level catalog contains 28 levels, not the planned 200-level campaign.
- The Codemagic production workflows require the `nexus_link_keystore`,
  `android_release`, `ios_release`, `admob_production`, and
  `CM_RECIPIENT_EMAIL` Codemagic configuration to exist before use.

## Required user actions

1. Supply registered Android and iOS application identifiers if the current placeholders are not final.
2. Supply production AdMob app IDs and banner/interstitial/rewarded unit IDs through a secure release configuration.
3. Create a release keystore and configure signing through a private, ignored properties file or CI secret store.
4. Repair/install the Android NDK version selected by Flutter.
5. Run Android release QA on physical devices and run iOS QA on a Mac with Xcode.
6. Review the factual data-collection summary before publishing privacy disclosures.
7. Provide approved store metadata, privacy policy, support contact, screenshots, and final artwork.

## Verified in this workspace

- Flutter analyzer passed.
- Automated regression suite passed with 37 tests.
- Level catalog validator passed for all 28 current definitions.
- Offline local progression and settings architecture are implemented.
- Production environment selection is explicit and does not invent IDs or credentials.

## Not verified here

- Signed Android AAB/APK generation.
- iOS release/archive build.
- Physical device, airplane-mode, ad, memory, thermal, and long-session testing.
- Store submission or legal compliance.
