// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ImageFlowCodeGen",
    platforms: [.macOS(.v15), .iOS(.v18)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(path: "../ImageFlowKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "CodeGen",
            ]
        ),
        .target(
            name: "CodeGen",
            dependencies: [
                .product(name: "Values", package: "ImageFlowKit"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
        ),
    ]
)
