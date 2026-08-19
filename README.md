# Jenkins Buddy

Jenkins Buddy is a native desktop client for monitoring Jenkins jobs without
keeping a browser dashboard open.

## Features

- Configure one Jenkins controller with a URL, user name, and API token.
- Browse available folders and jobs in a hierarchical tree.
- Open each monitored job in a dedicated, deduplicated tab.
- See current and recent build status at a glance.
- Switch the macOS interface live between ten languages.
- Receive configurable macOS notifications when builds start, succeed, fail,
  or become unstable.

## Platforms

| Platform | Status | Source |
| --- | --- | --- |
| macOS | Available | [`macos/`](macos/) |
| Windows | Planned | — |
| Linux | Planned | — |

Platform-specific source code, tests, documentation, and build tooling stay
inside the corresponding platform directory.

## macOS development

The current client is a native SwiftUI/AppKit application. Build and test it
from the `macos` directory:

```sh
cd macos
xcodebuild -project "Jenkins Buddy.xcodeproj" \
    -scheme "Jenkins Buddy" \
    -destination 'platform=macOS' \
    build
./scripts/test-with-coverage.sh
```

The test command enforces at least 90% application line coverage. See the
[macOS development guide](macos/README.md) for local release and distribution
builds.

## Security

Jenkins Buddy requires HTTPS with a system-trusted certificate, except for
plain HTTP connections to loopback development hosts. API tokens are stored in
the macOS Keychain and are never written to preferences or logs.

## License

Jenkins Buddy is available under the [Apache License 2.0](LICENSE).
