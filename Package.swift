// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ZTronSpendingSheet",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZTronSpendingSheet",
            targets: ["ZTronSpendingSheet"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZTronSpendingSheet",
            swiftSettings: [
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES"),
                .enableExperimentalFeature("StrictConcurrency=complete", .when(platforms: [.macOS, .iOS]))
            ]
        ),
        
        
        .testTarget(
            name: "ZTronSpendingSheetTests",
            dependencies: ["ZTronSpendingSheet"]
        ),
    ]
)
