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
        ///
        .library(name: "Backend"),
        .library(name: "Values"),
        .library(name: "Helpers"),
        .library(name: "Logging"),
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
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master"),
        .package(path: "../Packages/CIImageView"),
        .package(path: "../CubeLutKit"),
        .package(path: "../Packages/XViewKit"),
    ],
    targets: [
        .target(
            name: "AppMacOS",
            dependencies: [
                "Logging",
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
            ]
        ),
        .target(
            name: "AnimKit",
            dependencies: [
                "Helpers",
                "XKit",
            ]
        ),
        .target(name: "XKit"),
        .target(name: "Values"),
        .target(name: "Helpers"),
        .target(name: "Logging"),
        .target(
            name: "Controls",
            dependencies: [
                "Helpers",
                "Logging",
                "Values",
                "Design",
                "XKit",
            ]
        ),
        .target(
            name: "CardStage",
            dependencies: [
                "Helpers",
                "XViewKit",
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
                "Logging",
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
                "Logging",
                "CIImageView",
                "ImageExporter",
                "SharedMocking",
                "SettingsFeature",
                "CardStage",
            ]
        ),
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
                "Logging",
                "SharedModels",
            ]
        ),
        .target(
            name: "AssetBrowserFeature",
            dependencies: [
                "Logging",
                "Values",
                "Helpers",
                "SharedModels",
            ]
        ),
        .target(
            name: "CanvasView",
            dependencies: [
                "Helpers",
                "Logging",
                "Design",
                "XKit",
            ],
        ),
        .target(
            name: "NodeView",
            dependencies: [
                "Helpers",
                "Logging",
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
                "Logging",
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
                "Logging",
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
                "Logging",
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
                "Logging",
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
