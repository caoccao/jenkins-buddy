# Jenkins Buddy macOS instructions

All Apple-specific code, projects, assets, tests, scripts, and documentation must remain inside this `macos/` directory.

- Keep Models pure, Services UI-independent, ViewModels `@MainActor @Observable`, and Views focused on presentation and intent wiring.
- Use descriptive names, early guards, braces for every control-flow body, and no force unwraps or force casts.
- Keep production Swift files below 500 lines when a real responsibility boundary exists.
- Put layout metrics in documented `UIConstants.<Surface>` namespaces.
- Put user-visible strings in the localization catalog.
- Put accessibility identifiers on leaf controls, not parent containers.
- Use Swift Testing for unit tests and XCTest for UI-test contracts.
- Do not run UI tests unless the user explicitly requests them.

Build and test from this directory:

```sh
xcodebuild -project "Jenkins Buddy.xcodeproj" -scheme "Jenkins Buddy" -destination 'platform=macOS' build
./scripts/test-with-coverage.sh
```

Every change must be verified with a Release build before handoff. A successful
Debug build or test run does not replace this final check:

```sh
./build-release.sh
```

Use `./build-distribution.sh` only when intentionally preparing a signed
distribution archive and export. Do not run UI tests.
