#!/bin/sh
set -eu

repository_root=$(cd .. && pwd)
violations=$(find "$repository_root" -path "$repository_root/.git" -prune -o -path "$repository_root/macos" -prune -o \( -name '*.swift' -o -name '*.m' -o -name '*.mm' -o -name '*.xcodeproj' -o -name '*.xcworkspace' -o -name '*.entitlements' -o -name '*.xctestplan' \) -print)
if [ -n "$violations" ]; then
    echo "Apple implementation files found outside macos/:"
    echo "$violations"
    exit 1
fi
