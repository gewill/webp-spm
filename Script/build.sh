#!/bin/bash
# This script automates cloning libwebp and building Swift-compatible XCFrameworks.

set -e

# Version of libwebp to clone and build
WEBP_VERSION="v1.6.0"

# Directory layout
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="${ROOT_DIR}/build"
SRC_DIR="${BUILD_DIR}/libwebp"
FRAMEWORKS_DIR="${ROOT_DIR}/Frameworks"

echo "[*] Cleaning up old builds..."
rm -rf "${BUILD_DIR}"
rm -rf "${FRAMEWORKS_DIR}"
mkdir -p "${FRAMEWORKS_DIR}"
mkdir -p "${BUILD_DIR}"

echo "[*] Cloning libwebp repository (version ${WEBP_VERSION}) from GitHub..."
git clone --depth 1 --branch "${WEBP_VERSION}" https://github.com/webmproject/libwebp.git "${SRC_DIR}"

echo "[*] Injecting xcframeworkbuild.sh script..."
cp "${SCRIPT_DIR}/xcframeworkbuild.sh" "${SRC_DIR}/xcframeworkbuild.sh"
chmod +x "${SRC_DIR}/xcframeworkbuild.sh"

echo "[*] Building XCFrameworks (this may take a few minutes)..."
cd "${SRC_DIR}"
./xcframeworkbuild.sh
cd "${ROOT_DIR}"

echo "[*] Copying built frameworks to output folder..."
cp -R "${SRC_DIR}/"*.xcframework "${FRAMEWORKS_DIR}/"

echo "[*] Injecting modulemaps and umbrella headers for SPM support..."
chmod +x "${SCRIPT_DIR}/add_modulemaps.sh"
"${SCRIPT_DIR}/add_modulemaps.sh" "${FRAMEWORKS_DIR}"

echo "[*] Cleaning up build cache..."
rm -rf "${BUILD_DIR}"

echo "[*] Done! WebP XCFrameworks successfully compiled under Frameworks/"
