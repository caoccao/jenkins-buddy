#!/bin/bash
#
# build-release.sh — Build and sign a Release configuration of Jenkins Buddy.
#
# Output: ./build/Build/Products/Release/Jenkins Buddy.app
#
# This is the local release path: code-stripped, optimised, and signed for
# local testing with Jenkins Buddy's sandbox and network entitlements.
#
# It signs with the local self-signed "ccroot" code-signing identity. A stable
# signing identity gives the
# app a stable Designated Requirement so Keychain access remains valid across
# rebuilds. Ad-hoc signing changes identity every build and can invalidate
# existing Keychain access.

set -euo pipefail

cd "$(dirname "$0")"

PROJECT="Jenkins Buddy.xcodeproj"
SCHEME="Jenkins Buddy"
DERIVED_DATA="./build"
PRODUCT_PATH="${DERIVED_DATA}/Build/Products/Release/Jenkins Buddy.app"
PRODUCT_EXECUTABLE="${PRODUCT_PATH}/Contents/MacOS/Jenkins Buddy"

# Hardcoded release signing settings.
#
# SIGNING_IDENTITY names the local self-signed certificate used for repeatable
# local builds. The entitlements keep App Sandbox enabled and permit outbound
# network access to Jenkins controllers.
#
# USE_SECURE_TIMESTAMP requests a trusted timestamp from Apple's timestamp
# authority. It is only meaningful for distribution builds and needs network
# access, so it stays off for this local self-signed path.
SIGNING_IDENTITY="ccroot"
ENTITLEMENTS_PATH="./Jenkins Buddy/JenkinsBuddy.entitlements"
ENABLE_HARDENED_RUNTIME=1
USE_SECURE_TIMESTAMP=0

resolve_signing_identity() {
    if [ -n "${SIGNING_IDENTITY}" ]; then
        printf '%s\n' "${SIGNING_IDENTITY}"
        return 0
    fi

    printf '%s\n' "-"
}

prepare_entitlements() {
    if [ -n "${ENTITLEMENTS_PATH}" ]; then
        if [ ! -f "${ENTITLEMENTS_PATH}" ]; then
            echo "error: entitlements file is missing: ${ENTITLEMENTS_PATH}" >&2
            exit 1
        fi

        printf '%s\n' "${ENTITLEMENTS_PATH}"
        return 0
    fi

    return 0
}

is_hardened_runtime_enabled() {
    case "${ENABLE_HARDENED_RUNTIME}" in
        0|false|FALSE|False|no|NO|No)
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

is_secure_timestamp_enabled() {
    case "${USE_SECURE_TIMESTAMP}" in
        1|true|TRUE|True|yes|YES|Yes)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

sign_product() {
    local signing_identity="$1"
    local entitlements_path="$2"
    local -a codesign_arguments
    codesign_arguments=(--force --deep --sign "${signing_identity}")

    if is_hardened_runtime_enabled; then
        codesign_arguments+=(--options runtime)
    fi

    if [ -n "${entitlements_path}" ]; then
        codesign_arguments+=(--entitlements "${entitlements_path}")
    fi

    if is_secure_timestamp_enabled && [ "${signing_identity}" != "-" ]; then
        codesign_arguments+=(--timestamp)
    else
        codesign_arguments+=(--timestamp=none)
    fi

    echo
    echo "==> Signing ${PRODUCT_PATH}"
    echo "    Identity: ${signing_identity}"
    if [ -n "${entitlements_path}" ]; then
        echo "    Entitlements: ${entitlements_path}"
    fi

    /usr/bin/codesign "${codesign_arguments[@]}" "${PRODUCT_PATH}"
}

verify_product() {
    echo
    echo "==> Verifying code signature..."
    /usr/bin/codesign --verify --deep --strict --verbose=2 "${PRODUCT_PATH}"
    /usr/bin/codesign -dv --verbose=2 "${PRODUCT_PATH}" 2>&1 \
        | sed -n '/^Executable=/p;/^Identifier=/p;/^TeamIdentifier=/p;/^Signature=/p;/^Authority=/p'
}

echo "==> Building ${SCHEME} (Release)…"
xcodebuild \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -destination 'platform=macOS' \
    -derivedDataPath "${DERIVED_DATA}" \
    build

if [ ! -x "${PRODUCT_EXECUTABLE}" ]; then
    echo "error: built executable is missing or not executable: ${PRODUCT_EXECUTABLE}" >&2
    exit 1
fi

RESOLVED_SIGNING_IDENTITY="$(resolve_signing_identity)"
RESOLVED_ENTITLEMENTS_PATH="$(prepare_entitlements)"
sign_product "${RESOLVED_SIGNING_IDENTITY}" "${RESOLVED_ENTITLEMENTS_PATH}"
verify_product

echo
echo "==> Built: ${PRODUCT_PATH}"
ls -ld "${PRODUCT_PATH}"
