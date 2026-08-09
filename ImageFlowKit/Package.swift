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
        .library(name: "SharedControllers"),
        .library(name: "PreviewFeature"),
        .library(name: "NodePaletteFeature"),
        .library(name: "ImageExporter"),
        .library(name: "AssetSystem"),
        .library(name: "AssetBrowserFeature"),
        .library(name: "CanvasView"),
        .library(name: "NodeView"),
        .library(name: "CanvasFeature"),
        .library(name: "SidebarFeature"),
        .library(name: "FlowDocument"),
        .library(name: "BackendService"),
        .library(name: "SettingsFeature"),
        .library(name: "ContextMenus"),
        .library(name: "InspectorFeature"),
        .library(name: "TextInput"),
        .library(name: "CardStage"),
        .library(name: "CubeLutKit"),
        .library(name: "ComponentKit"),
        .library(name: "Filters"),
        .library(name: "FormatKit"),
    ],
    dependencies: [
        .package(url: "https://github.com/davecom/SwiftGraph.git", branch: "master"),
        .package(url: "https://github.com/in2core/swift-cikernel-plugin.git", branch: "main"),
    ],
    targets: [
        .executableTarget(name: "GenerateNodeIndex", dependencies: ["SharedModels"]),
        .target(name: "FormatKit", dependencies: ["Helpers"]),
        .target(
            name: "Filters",
            dependencies: ["Values"],
            exclude: ["Kernels"],
            plugins: [
                .plugin(name: "Swift-CIKernel", package: "Swift-CIKernel-Plugin")
            ]
        ),
        .target(
            name: "AppMacOS",
            dependencies: [
                "Helpers",
                "Backend",
                "SharedModels",
                "SharedControllers",
                "SettingsFeature",
                "SidebarFeature",
                "CanvasFeature",
                "AssetBrowserFeature",
                "BackendService",
                "NodeView",
                "ImageExporter",
                "NodePaletteFeature",
                "AssetSystem",
                "InspectorFeature",
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
        .target(
            name: "ComponentKit",
            dependencies: ["Helpers", "XKit", "Filters", "Values", "FormatKit"],
            resources: [.process("Resources")]
        ),
        .target(name: "Values", dependencies: ["Helpers"]),
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
                "Filters",
            ],
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
            name: "SharedControllers",
            dependencies: [
                "Helpers",
                "SharedModels",
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
                "SettingsFeature",
                "CardStage",
                "AssetSystem",
                "ComponentKit",
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
                "Design",
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
            name: "AssetSystem",
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
                "SharedControllers",
                "AssetSystem",
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
                "ComponentKit",
                "SettingsFeature",
                "FormatKit",
            ]
        ),
        .target(
            name: "CanvasFeature",
            dependencies: [
                "Helpers",
                "Design",
                "CanvasView",
                "SharedModels",
                "SharedControllers",
                "NodeView",
                "PreviewFeature",
                "NodePaletteFeature",
                "ContextMenus",
                "XKit",
                "AssetSystem",
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
            name: "FlowDocument",
            dependencies: [
                "Helpers",
                "CanvasFeature",
                "AssetSystem",
            ]
        ),
        .target(
            name: "BackendService",
            dependencies: [
                "Backend",
                "Helpers",
                "SharedModels",
                "AssetSystem",
            ]
        ),
        .target(
            name: "SettingsFeature",
            dependencies: [
                "XKit",
                "Helpers",
                "SharedModels",
                "ComponentKit",
                "FormatKit",
            ],
            resources: [.process("Resources")],
        ),
        .target(
            name: "ContextMenus",
            dependencies: [
                "SharedModels",
                "Helpers",
                "SharedControllers",
            ]
        ),
        .target(
            name: "InspectorFeature",
            dependencies: [
                "Helpers",
                "Controls",
                "Design",
                "SharedModels",
                "Backend",
                "Values",
                "TextInput",
                "ContextMenus",
                "ComponentKit",
                "SettingsFeature",
                "FormatKit",
            ]
        ),
        .target(
            name: "TextInput",
            dependencies: [
                "Helpers",
                "Design",
                "XKit",
                "FormatKit",
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
            name: "ComponentKitTests",
            dependencies: [
                "ComponentKit"
            ]
        ),
        .testTarget(
            name: "CubeLutKitTests",
            dependencies: ["CubeLutKit"]
        ),
        // .testTarget(
        //     name: "AssetManagerTests",
        //     dependencies: [
        //         "SharedModels",
        //         "AssetManager",
        //     ],
        //     resources: [.copy("Fixtures")]
        // ),
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
