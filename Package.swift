// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-semantic-version",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-semantic-version",
            targets: ["swift-semantic-version"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-semantic-version"),
        .testTarget(
            name: "swift-semantic-versionTests",
            dependencies: ["swift-semantic-version"]
        ),
    ]
)
