# WebP for Swift Package Manager (webp-spm)

> [!IMPORTANT]
> This is an unofficial community package.
> It is not affiliated with, endorsed by, or maintained by Google.

This Swift Package wraps Google's official WebP image format library (`libwebp`) into multi-platform C/Swift modules. It provides prebuilt **XCFrameworks** supporting macOS (Intel & Apple Silicon) and iOS (Devices & Simulators) out of the box, with zero bridging header configuration required.

## Target Platform Support

* **macOS**: `arm64` (Apple Silicon) & `x86_64` (Intel)
* **macOS Catalyst**: `arm64` & `x86_64`
* **iOS**: `arm64` (Devices)
* **iOS Simulator**: `arm64` & `x86_64`

---

## Comparison with Official Prebuilt Frameworks

This package offers several advantages over the prebuilt iOS/macOS frameworks downloadable from Google's official WebP website:

| Feature | Official Prebuilt Frameworks | webp-spm (This Package) |
| :--- | :--- | :--- |
| **Swift `import WebP`** | ❌ **No**. Lacks Clang module maps. Requires manual bridging headers. |  **Yes**. Pre-configured with custom `module.modulemap` and umbrella headers for direct Swift import. |
| **Swift Package Manager** | ❌ **No**. Must be manually integrated or wrapped. |  **Yes**. Ready-to-use local or remote SPM package. |
| **Modern Architecture** | ⚠️ Includes deprecated 32-bit bloat (`armv7`, `armv7s`, `i386`). |  **64-bit Only**. Optimized for modern iOS devices and Apple Silicon/Intel simulators. |
| **Format Standard** | Contains legacy `.framework` fat files (prone to M1 simulator conflicts). |  **XCFramework Only**. Uses Apple's recommended modern package format. |
| **Automation toolchain** | ⚠️ **Has official script** but stable tags contain broken 32-bit targets on modern macOS, and it lacks SPM modulemap injection. |  **Yes**. Includes an automated wrapper (`Script/build.sh`) that clones, compiles with 64-bit modern fixes, and injects module maps. |

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

## Running the Example

We have included a runnable Swift example target (`WebPExample`) to demonstrate how to call WebP C APIs in Swift on macOS.

To run the example:
1. Clone this repository locally.
2. Run in terminal:
   ```bash
   swift run WebPExample
   ```

This example will:
* Download 3 copyright-free images from the web.
* Convert them to raw RGBA pixels using macOS native Cocoa (`NSImage`/`CGImage`) APIs.
* Compress the pixels to WebP format using `WebPEncodeRGBA` (quality 80) and print size comparisons.
* Decode them back to raw pixels using `WebPDecodeRGBA` and save them back as PNGs.
* **All output images (`.webp` and `_decoded.png`) will be neatly saved inside the `Outputs/` directory.**

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
