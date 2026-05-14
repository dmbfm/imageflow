// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Product {
    static func library(name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

let package = Package(
    name: "ImageFlowKit",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        .library(name: "AppMacOS"),
        .library(name: "AnimKit"),
        .library(name: "XKit"),
        .library(name: "CIImageView"),
        .library(name: "Backend"),
        .library(name: "Values"),
        .library(name: "Helpers"),
        .library(name: "Controls"),
        .library(name: "Design"),
        .library(name: "SharedModels"),
        .library(name: "PreviewFeature"),
        .library(name: "NodePaletteFeature"),
        .library(name: "ImageExporter"),
        .library(name: "AssetManager"),
        .library(name: "AssetBrowserFeature"),
        .library(name: "CanvasView"),
        .library(name: "NodeView"),
        .library(name: "CanvasFeature"),
        .library(name: "SidebarFeature"),
        .library(name: "WelcomeWindow"),
        .library(name: "FlowDocument"),
        .library(name: "BackendService"),
        .library(name: "SettingsFeature"),
        .library(name: "ContextMenus"),
        .library(name: "InspectorFeature"),
        .library(name: "TextInput"),
        .library(name: "CardStage"),
        .library(name: "CubeLutKit"),
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master")
    ],
    targets: [
        .target(
            name: "AppMacOS",
            dependencies: [
                "Helpers",
                "Backend",
                "SharedModels",
                "SettingsFeature",
                "SidebarFeature",
                "CanvasFeature",
                "AssetManager",
                "AssetBrowserFeature",
                "BackendService",
                "NodeView",
                "ImageExporter",
            ]
        ),
        .target(
            name: "AnimKit",
            dependencies: [
                "Helpers",
                "XKit",
            ]
        ),
        .target(name: "XKit", dependencies: ["Helpers"]),
        .target(name: "Values"),
        .target(name: "Helpers"),
        .target(name: "CubeLutKit"),
        .target(
            name: "Controls",
            dependencies: [
                "Helpers",
                "Values",
                "Design",
                "XKit",
            ]
        ),
        .target(
            name: "CardStage",
            dependencies: [
                "Helpers",
                "AnimKit",
            ]
        ),
        .target(
            name: "Backend",
            dependencies: [
                "Values",
                "SwiftGraph",
                "CubeLutKit",
                "Helpers",
            ]
        ),
        .target(
            name: "SharedModels",
            dependencies: [
                "Backend",
                "Helpers",
                "Values",
            ]
        ),
        .target(
            name: "PreviewFeature",
            dependencies: [
                "Backend",
                "Design",
                "Controls",
                "SharedModels",
                "Helpers",
                "Values",
                "CIImageView",
                "ImageExporter",
                "SharedMocking",
                "SettingsFeature",
                "CardStage",
            ]
        ),
        .target(name: "CIImageView", dependencies: ["XKit", "Helpers"]),
        .target(
            name: "NodePaletteFeature",
            dependencies: [
                "Helpers",
                "SharedModels",
                "Values",
                "XKit",
            ]
        ),
        .target(
            name: "Design",
            dependencies: ["Helpers"]
        ),
        .target(
            name: "ImageExporter",
            dependencies: [
                "Helpers",
                "Controls",
            ]
        ),
        .target(
            name: "AssetManager",
            dependencies: [
                "Backend",
                "Helpers",
                "Values",
                "SharedModels",
            ]
        ),
        .target(
            name: "AssetBrowserFeature",
            dependencies: [
                "Values",
                "Helpers",
                "SharedModels",
            ]
        ),
        .target(
            name: "CanvasView",
            dependencies: [
                "Helpers",
                "Design",
                "XKit",
            ],
        ),
        .target(
            name: "NodeView",
            dependencies: [
                "Helpers",
                "Controls",
                "CanvasView",
                "Design",
                "Values",
                "Backend",
                "SharedModels",
                "TextInput",
            ]
        ),
        .target(
            name: "CanvasFeature",
            dependencies: [
                "Helpers",
                "Design",
                "CanvasView",
                "SharedModels",
                "NodeView",
                "PreviewFeature",
                "NodePaletteFeature",
                "ContextMenus",
                "XKit",
            ],
        ),
        .target(
            name: "SidebarFeature",
            dependencies: [
                "Backend",
                "SharedModels",
            ]
        ),
        .target(
            name: "WelcomeWindow",
            dependencies: [
                "SharedModels",
                "SettingsFeature",
            ]
        ),
        .target(
            name: "FlowDocument",
            dependencies: [
                "Helpers",
                "CanvasFeature",
                "AssetManager",
            ]
        ),
        .target(
            name: "SharedMocking",
            dependencies: [
                "SharedModels",
                "Helpers",
            ]
        ),
        .target(
            name: "BackendService",
            dependencies: [
                "Backend",
                "Helpers",
                "SharedModels",
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: []
        ),
        .target(
            name: "ContextMenus",
            dependencies: [
                "SharedModels",
                "Helpers",
            ]
        ),
        .target(
            name: "InspectorFeature",
            dependencies: [
                "Helpers",
                "Controls",
                "Design",
                "SharedModels",
                "SharedMocking",
                "Backend",
                "Values",
                "TextInput",
            ]
        ),
        .target(
            name: "TextInput",
            dependencies: [
                "Helpers",
                "Design",
                "XKit",
            ],
        ),
        .testTarget(
            name: "SharedModelsTests",
            dependencies: [
                "Backend",
                "SharedModels",
                "Values",
            ]
        ),
        .testTarget(
            name: "HelpersTests",
            dependencies: [
                "Helpers"
            ]
        ),
        .testTarget(
            name: "CubeLutKitTests",
            dependencies: ["CubeLutKit"]
        ),
        .testTarget(
            name: "AssetManagerTests",
            dependencies: [
                "SharedModels",
                "AssetManager",
            ],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "CardStageTests",
            dependencies: [
                "CardStage",
                "Helpers",
            ]
        ),
    ]
)

// Enable the NonisolatedNonsendingByDefault experimental feature
for target in package.targets {
    var settings = target.swiftSettings ?? []
    let features = [
        "NonisolatedNonsendingByDefault",
        "InferIsolatedConformances",
    ]
    for feat in features {
        settings.append(.enableExperimentalFeature(feat))
    }
    target.swiftSettings = settings
}
