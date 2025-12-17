// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CIImageView",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CIImageView",
            targets: ["CIImageView"]
        )
    ],
    dependencies: [
        .package(path: "../XViewKit"),
        .package(url: "https://github.com/dmbfm/CoreGraphicsEx.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CIImageView",
            dependencies: [
                "XViewKit",
                "CoreGraphicsEx",
            ]
        ),
        .executableTarget(
            name: "Preview",
            dependencies: [
                "CoreGraphicsEx",
                "CIImageView",
            ],
            resources: [.process("Assets")],
        ),
        .testTarget(
            name: "CIImageViewTests",
            dependencies: ["CIImageView"]
        ),
    ]
)
