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
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Backend"),
        .library(name: "Values"),
        .library(name: "ImageFlowKit"),
        .library(name: "Helpers"),
        .library(name: "Logging"),
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master")
    ],
    targets: [
        .target(name: "Values"),
        .target(name: "Helpers"),
        .target(name: "Logging"),
        .target(name: "Backend", dependencies: ["Values", "SwiftGraph"]),
        .target(name: "ImageFlowKit", dependencies: ["Values", "Backend", "Helpers", "Logging"]),
        .testTarget(
            name: "ImageFlowKitTests",
            dependencies: ["ImageFlowKit", "Backend", "Values"],
            resources: [.copy("Fixtures")]
        ),
    ]
)

// Enable the NonisolatedNonsendingByDefault experimental feature
for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("NonisolatedNonsendingByDefault"))
    target.swiftSettings = settings
}
