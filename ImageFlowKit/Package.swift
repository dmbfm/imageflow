// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Product {
    static func library(name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

let package = Package(
    name: "ImageFlowKit",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(name: "ImageFlowKit", targets: ["ImageFlowKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "ImageFlowKit",
            dependencies: [
                .product(name: "SwiftGraph", package: "SwiftGraph")
            ]
        ),
        .testTarget(
            name: "ImageFlowKitTests",
            dependencies: [
                "ImageFlowKit",
                .product(name: "SwiftGraph", package: "SwiftGraph")
            ]
        )
    ]
)

// Enable the NonisolatedNonsendingByDefault experimental feature
for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("NonisolatedNonsendingByDefault"))
    target.swiftSettings = settings
}
