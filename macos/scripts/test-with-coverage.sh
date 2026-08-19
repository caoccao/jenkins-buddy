#!/bin/sh

set -eu

result_path=".build/TestResults-$(date +%s).xcresult"

xcodebuild \
    -project "Jenkins Buddy.xcodeproj" \
    -scheme "Jenkins Buddy" \
    -configuration Debug \
    -derivedDataPath .build/DerivedData \
    -resultBundlePath "$result_path" \
    -destination 'platform=macOS' \
    -enableCodeCoverage YES \
    CODE_SIGNING_ALLOWED=NO \
    test

./scripts/check-coverage.sh "$result_path"
