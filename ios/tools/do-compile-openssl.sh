#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Bilibili
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script is based on projects below
# https://github.com/x2on/OpenSSL-for-iPhone

# Build the same optional OpenSSL source used by Android.
set -e
FF_BUILD_ROOT=$(cd "$(dirname "$0")/.." && pwd)
FF_ARCH=$1
IOS_DEPLOYMENT_TARGET=${IOS_DEPLOYMENT_TARGET:-15.0}
case "$FF_ARCH" in
    arm64) OPENSSL_TARGET=ios64-xcrun; SDK=iphoneos; MIN_VERSION=-miphoneos-version-min=$IOS_DEPLOYMENT_TARGET ;;
    x86_64) OPENSSL_TARGET=iossimulator-x86_64-xcrun; SDK=iphonesimulator; MIN_VERSION=-mios-simulator-version-min=$IOS_DEPLOYMENT_TARGET ;;
    *) echo "Unsupported architecture: $FF_ARCH (use arm64 or x86_64)"; exit 1 ;;
esac
FF_SOURCE="$FF_BUILD_ROOT/../extra/openssl"
FF_PREFIX="$FF_BUILD_ROOT/build/openssl-$FF_ARCH/output"
if [ ! -f "$FF_SOURCE/Configure" ]; then
    echo "Cannot find OpenSSL at $FF_SOURCE; initialize it before building."
    exit 1
fi
SDK_PATH=$(xcrun --sdk "$SDK" --show-sdk-path)
export CC="$(xcrun --sdk "$SDK" --find clang)"
export AR="$(xcrun --sdk "$SDK" --find ar)"
export RANLIB="$(xcrun --sdk "$SDK" --find ranlib)"
export NM="$(xcrun --sdk "$SDK" --find nm)"
export CFLAGS="-arch $FF_ARCH -isysroot $SDK_PATH $MIN_VERSION"
export LDFLAGS="$CFLAGS"
unset CROSS_COMPILE
cd "$FF_SOURCE"
# The source is shared with Android: never reuse another target's configuration.
if [ -f Makefile ]; then
    make distclean
fi
./Configure "$OPENSSL_TARGET" no-shared no-tests no-apps no-legacy no-quic \
    --prefix="$FF_PREFIX" --openssldir="$FF_PREFIX" --libdir=lib
make -j"$(sysctl -n hw.ncpu)"
make install_sw
