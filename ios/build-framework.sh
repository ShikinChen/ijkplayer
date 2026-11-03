#!/usr/bin/env bash
# Package the local device framework consumed by IJKMediaFramework.podspec.
set -euo pipefail
IOS_ROOT=$(cd "$(dirname "$0")" && pwd)
if [ ! -f "$IOS_ROOT/build/universal/lib/libavcodec.a" ]; then
    echo "Build FFmpeg first: $IOS_ROOT/compile-ffmpeg.sh arm64" >&2
    exit 1
fi
xcodebuild \
    -project "$IOS_ROOT/IJKMediaPlayer/IJKMediaPlayer.xcodeproj" \
    -scheme IJKMediaFramework -configuration Release \
    -sdk iphoneos -destination 'generic/platform=iOS' \
    -derivedDataPath "$IOS_ROOT/build/framework-derived" \
    CONFIGURATION_BUILD_DIR="$IOS_ROOT/build/framework/iphoneos" \
    CODE_SIGNING_ALLOWED=NO build

# Keep the distributable pod self-contained so it can be copied to another app.
PACKAGE_ROOT="$IOS_ROOT/IJKMediaFramework"
mkdir -p "$PACKAGE_ROOT/Licenses"
rm -rf "$PACKAGE_ROOT/IJKMediaFramework.framework"
cp -R "$IOS_ROOT/build/framework/iphoneos/IJKMediaFramework.framework" "$PACKAGE_ROOT/"
cp "$IOS_ROOT/../COPYING.LGPLv2.1" "$PACKAGE_ROOT/LICENSE.txt"
cp "$IOS_ROOT/../COPYING.LGPLv2.1" "$PACKAGE_ROOT/Licenses/FFmpeg-LGPL-2.1.txt"
if [ -f "$IOS_ROOT/../extra/openssl/LICENSE.txt" ]; then
    cp "$IOS_ROOT/../extra/openssl/LICENSE.txt" "$PACKAGE_ROOT/Licenses/OpenSSL.txt"
fi
echo "Local CocoaPods package: $PACKAGE_ROOT"
