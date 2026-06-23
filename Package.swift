// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebP",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "WebP", targets: ["WebP"]),
        .library(name: "WebPDecoder", targets: ["WebPDecoder"]),
        .library(name: "WebPDemux", targets: ["WebPDemux"]),
        .library(name: "WebPMux", targets: ["WebPMux"]),
        .library(name: "SharpYuv", targets: ["SharpYuv"]),
        .executable(name: "WebPExample", targets: ["WebPExample"])
    ],
    targets: [
        .target(
            name: "WebPExample",
            dependencies: ["WebP", "SharpYuv"],
            path: "Sources/WebPExample"
        ),
        .binaryTarget(
            name: "WebP",
            path: "Frameworks/WebP.xcframework"
        ),
        .binaryTarget(
            name: "WebPDecoder",
            path: "Frameworks/WebPDecoder.xcframework"
        ),
        .binaryTarget(
            name: "WebPDemux",
            path: "Frameworks/WebPDemux.xcframework"
        ),
        .binaryTarget(
            name: "WebPMux",
            path: "Frameworks/WebPMux.xcframework"
        ),
        .binaryTarget(
            name: "SharpYuv",
            path: "Frameworks/SharpYuv.xcframework"
        )
    ]
)
