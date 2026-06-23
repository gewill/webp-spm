# WebP for Swift Package Manager (webp-spm)

This Swift Package wraps Google's official WebP image format library (`libwebp`) into multi-platform C/Swift modules. It provides prebuilt **XCFrameworks** supporting macOS (Intel & Apple Silicon) and iOS (Devices & Simulators) out of the box, with zero bridging header configuration required.

## Target Platform Support

* **macOS**: `arm64` (Apple Silicon) & `x86_64` (Intel)
* **macOS Catalyst**: `arm64` & `x86_64`
* **iOS**: `arm64` (Devices)
* **iOS Simulator**: `arm64` & `x86_64`

## Usage

Add this package to your Swift project using Swift Package Manager.

### In your Xcode Project:
1. Go to **File** -> **Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/gewill/webp-spm.git` (or use local path if consuming locally).
3. Select the products you want to use and add them to your target.

### In Swift code:
Simply import the target you need:
```swift
import WebP

// You can now call WebP C functions directly in Swift!
let version = WebPGetDecoderVersion()
print("WebP Version: \(version)")
```

### Frameworks Overview

* **`WebP`**: Standard full encoder/decoder library.
* **`WebPDecoder`**: Minimal decoder library (ideal for apps only showing images).
* **`WebPDemux`**: Helper for extracting metadata and parsing animations.
* **`WebPMux`**: Helper for compiling metadata and creating animations.
* **`SharpYuv`**: Color space converter (internal dependency).

---

## Rebuilding from Source

If you wish to update or recompile the frameworks from source:

1. Clone this repository locally.
2. Open terminal and run:
   ```bash
   ./Script/build.sh
   ```
This script will:
* Clone the official `libwebp` repository from GitHub at a specific tag (e.g. `v1.6.0`).
* Build multi-platform static libraries using Xcode's compilers and toolchains.
* Merge them into a single set of XCFrameworks using `lipo` and `xcodebuild`.
* Inject Swift-compatible `modulemap` and umbrella headers.
* Overwrite the prebuilt binaries in the `Frameworks/` directory.
