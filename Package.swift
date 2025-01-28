// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ZTronSpendingSheet",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZTronSpendingSheet",
            targets: ["ZTronSpendingSheet"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/elai950/AlertToast", branch: "master"
        ),
        
        .package(
            url: "https://github.com/exyte/ScalingHeaderScrollView", branch: "master"
        ),
        
        .package(
            url: "https://github.com/jasudev/AxisTabView", branch: "main"
        ),

        .package(
            url: "https://github.com/globulus/swiftui-side-menu", branch: "main"
        ),
        
        .package(
            url: "https://github.com/ciaranrobrien/SwiftUIMasonry", branch: "main"
        ),
        
        .package(
            url: "https://github.com/ukushu/Ifrit", branch: "main"
        )
    ],
    targets: [
        .target(
            name: "ZTronSpendingSheet",
            dependencies: [
                .product(name: "ScalingHeaderScrollView", package: "ScalingHeaderScrollView"),
                .product(name: "AxisTabView", package: "AxisTabView"),
                .product(name: "SwiftUISideMenu", package: "swiftui-side-menu"),
                .product(name: "SwiftUIMasonry", package: "SwiftUIMasonry"),
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "Ifrit", package: "Ifrit"),
            ],
            resources: [
                // Include resource files.
                .process("Resources")
            ],
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
