// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "YTKKeyValueStore",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(name: "YTKKeyValueStore", targets: ["YTKKeyValueStore"]),
    ],
    dependencies: [
        .package(name: "FMDB", url: "https://github.com/ccgus/fmdb", .upToNextMinor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "YTKKeyValueStore",
            dependencies: [.product(name: "FMDB", package: "FMDB")],
            path: "YTKKeyValueStore",
            sources: ["YTKKeyValueStore.h", "YTKKeyValueStore.m"],
            linkerSettings: [
                .linkedLibrary("sqlite", .when(platforms: [.iOS, .macOS]))
            ]
        )
    ]
)
