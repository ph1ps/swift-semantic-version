// swift-tools-version: 6.1
import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-semantic-version",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(name: "SemanticVersion", targets: ["SemanticVersion"]),
    .library(name: "SemanticVersionMacro", targets: ["SemanticVersionMacro"])
  ],
  traits: [
    "FoundationBackend",
    "StringProcessingBackend",
    .default(enabledTraits: ["FoundationBackend"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"602.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.2")
  ],
  targets: [
    .target(
      name: "SemanticVersion",
      dependencies: [
        "_SemanticVersionBackendCore",
        .target(name: "_SemanticVersionBackendFoundation", condition: .when(traits: ["FoundationBackend"])),
        .target(name: "_SemanticVersionBackendStringProcessing", condition: .when(traits: ["StringProcessingBackend"]))
      ]
    ),
    .target(
      name: "_SemanticVersionBackendCore"
    ),
    .target(
      name: "_SemanticVersionBackendFoundation",
      dependencies: ["_SemanticVersionBackendCore"]
    ),
    .target(
      name: "_SemanticVersionBackendStringProcessing",
      dependencies: ["_SemanticVersionBackendCore"]
    ),
    .target(
      name: "SemanticVersionMacro",
      dependencies: [
        "SemanticVersion",
        "SemanticVersionMacroPlugin"
      ]
    ),
    .macro(
      name: "SemanticVersionMacroPlugin",
      dependencies: [
        "_SemanticVersionBackendFoundation",
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "SemanticVersionTests",
      dependencies: [
        "_SemanticVersionBackendFoundation",
        "_SemanticVersionBackendStringProcessing",
        "SemanticVersion",
        "SemanticVersionMacro",
        "SemanticVersionMacroPlugin",
        .product(name: "MacroTesting", package: "swift-macro-testing")
      ]
    )
  ]
)
