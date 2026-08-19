# Jenkins Buddy for macOS

Native SwiftUI/AppKit Jenkins monitoring client. The macOS implementation is self-contained in this directory.

The interface can be switched live between English, Spanish, French, German,
Portuguese, Simplified Chinese, Traditional Chinese for Hong Kong or Taiwan,
Japanese, and Korean from the Language section in Settings.

## Build

```sh
xcodebuild -project "Jenkins Buddy.xcodeproj" -scheme "Jenkins Buddy" -destination 'platform=macOS' build
```

For an optimized local app signed with the stable `ccroot` identity:

```sh
./build-release.sh
```

The app is written to `build/Build/Products/Release/Jenkins Buddy.app`.

To intentionally create a Developer ID archive and exported app for external
distribution, first configure an appropriate signing certificate and then run:

```sh
./build-distribution.sh
```

The distribution script writes `build/JenkinsBuddy.xcarchive` and
`build/export/Jenkins Buddy.app`; notarization and stapling remain explicit
follow-up steps printed by the script.

## Unit tests and coverage

```sh
./scripts/test-with-coverage.sh
```

The shared scheme runs the Swift Testing unit/rendering suite against the complete app target. The script fails if application line coverage drops below 90%. UI test sources are intentionally excluded from the shared test action and are not executed by this command.

Jenkins Buddy requires HTTPS with a system-trusted certificate; plain HTTP is accepted only for loopback development hosts. The API token is stored in Keychain under the normalized controller/user identity and is never written to UserDefaults or logs.
