#!/usr/bin/env bash
#
# build-distribution.sh — Archive and export Jenkins Buddy for
# distribution outside this machine.
#
# Outputs:
#   ./build/JenkinsBuddy.xcarchive   the signed archive
#   ./build/export/Jenkins Buddy.app the exported app bundle
#
# Requires a valid Developer ID certificate in the login keychain
# (see exportOptions.plist for the signing method). After this
# script finishes, notarise + staple the .app:
#
#   xcrun notarytool submit "./build/export/Jenkins Buddy.app" \
#       --apple-id YOU --team-id TEAM --password APP_SPECIFIC --wait
#   xcrun stapler staple "./build/export/Jenkins Buddy.app"

set -euo pipefail

cd "$(dirname "$0")"

PROJECT="Jenkins Buddy.xcodeproj"
SCHEME="Jenkins Buddy"
ARCHIVE_PATH="./build/JenkinsBuddy.xcarchive"
EXPORT_PATH="./build/export"
EXPORT_OPTIONS="./exportOptions.plist"

if [ ! -f "${EXPORT_OPTIONS}" ]; then
    echo "error: ${EXPORT_OPTIONS} is missing." >&2
    echo "       Edit it to match your signing setup before running this script." >&2
    exit 1
fi

# Clear previous outputs so xcodebuild doesn't refuse to overwrite.
rm -rf "${ARCHIVE_PATH}" "${EXPORT_PATH}"

echo "==> Archiving ${SCHEME} (Release)…"
xcodebuild archive \
    -project "${PROJECT}" \
    -scheme "${SCHEME}" \
    -configuration Release \
    -destination 'platform=macOS' \
    -archivePath "${ARCHIVE_PATH}"

echo
echo "==> Exporting archive to ${EXPORT_PATH}…"
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS}"

echo
echo "==> Done."
echo "    Archive: ${ARCHIVE_PATH}"
echo "    App:     ${EXPORT_PATH}/Jenkins Buddy.app"
echo
echo "Next steps for distribution:"
echo "  xcrun notarytool submit \"${EXPORT_PATH}/Jenkins Buddy.app\" \\"
echo "      --apple-id YOU --team-id TEAM --password APP_SPECIFIC --wait"
echo "  xcrun stapler staple \"${EXPORT_PATH}/Jenkins Buddy.app\""
