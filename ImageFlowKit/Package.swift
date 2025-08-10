// swift-tools-version: 6.1
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
        .library(name: "AppKitUtils"),
        .library(name: "Backend"),
        .library(name: "ColorUtils"),
        .library(name: "CommonUtils"),
        .library(name: "Design"),
        .library(name: "Easing"),
        .library(name: "EventEmitter"),
        .library(name: "IPadApp"),
        .library(name: "Logging"),
        .library(name: "MacApp"),
        .library(name: "Models"),
        .library(name: "NodeControls"),
        .library(name: "NodeView"),
        .library(name: "PlatformUtils"),
        .library(name: "SwiftUIUtils"),
        .library(name: "Values"),
        .library(name: "CanvasView"),
        .library(name: "CanvasFeature"),
        .library(name: "NodeDataStore"),
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppKitUtils",
            dependencies: [
                "CommonUtils"
            ],
        ),
        .target(
            name: "Backend",
            dependencies: [
                "SwiftGraph",
                "Values",
                "CommonUtils",
            ],
        ),
        .target(
            name: "ColorUtils",
            dependencies: [
                "Easing",
                "CommonUtils",
            ],
        ),
        .target(
            name: "CommonUtils"
        ),
        .target(
            name: "Design",
            dependencies: [
                "ColorUtils"
            ]
        ),
        .target(
            name: "Easing",
            dependencies: [],
        ),
        .target(
            name: "EventEmitter",
            dependencies: [],
        ),
        .target(
            name: "IPadApp",
            dependencies: [
                "Backend",
                "Models",
            ],
        ),
        .target(
            name: "Logging",
        ),
        .target(
            name: "MacApp",
            dependencies: [
                .target(name: "AppKitUtils", condition: .when(platforms: [.macOS])),
                "Logging",
                "CanvasFeature",
                "NodeDataStore",
            ],
        ),
        .target(
            name: "Models",
            dependencies: [
                "Logging",
                "Values",
                "Backend",
                "ColorUtils",
            ],
        ),
        .target(
            name: "NodeControls",
            dependencies: [
                "CommonUtils",
                "SwiftUIUtils",
                "Logging",
                "Models",
                "Design",
                "PlatformUtils",
                "ColorUtils",
                "Values",
            ],
        ),
        .target(
            name: "NodeView",
            dependencies: [
                .target(name: "AppKitUtils", condition: .when(platforms: [.macOS])),
                "CommonUtils",
                "SwiftUIUtils",
                "PlatformUtils",
                "Logging",
                "Models",
                "Design",
                "NodeControls",
                "CanvasView",
            ],
        ),
        .target(
            name: "PlatformUtils",
            dependencies: [
                .target(name: "AppKitUtils", condition: .when(platforms: [.macOS])),
                "ColorUtils",
            ],
        ),
        .target(
            name: "SwiftUIUtils",
            dependencies: [
                "Logging",
                "CommonUtils",
            ],
        ),
        .target(
            name: "Values",
        ),
        .target(
            name: "CanvasView",
            dependencies: [
                "Logging",
                "Design",
                "CommonUtils",
                "EventEmitter",
                "PlatformUtils",
                "SwiftUIUtils",
                "ColorUtils",
                .target(name: "AppKitUtils", condition: .when(platforms: [.macOS])),
            ]
        ),
        .target(
            name: "CanvasFeature",
            dependencies: [
                "Backend",
                "Logging",
                "CanvasView",
                "NodeView",
                "NodeDataStore",
                "SwiftUIUtils",
            ],
        ),
        .target(
            name: "NodeDataStore",
            dependencies: [
                "Backend",
                "Models",
                "Values",
                "CommonUtils",
            ],
        ),
    ]
)
