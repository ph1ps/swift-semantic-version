// swift-tools-version: 6.1
import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-semantic-version",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .macCatalyst(.v13),
    .tvOS(.v13),
    .watchOS(.v6),
    .visionOS(.v1)
  ],
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
        "SemanticVersionBackendCore",
        .target(name: "SemanticVersionBackendFoundation", condition: .when(traits: ["FoundationBackend"])),
        .target(name: "SemanticVersionBackendStringProcessing", condition: .when(traits: ["StringProcessingBackend"]))
      ]
    ),
    .target(
      name: "SemanticVersionBackendCore"
    ),
    .target(
      name: "SemanticVersionBackendFoundation",
      dependencies: ["SemanticVersionBackendCore"]
    ),
    .target(
      name: "SemanticVersionBackendStringProcessing",
      dependencies: ["SemanticVersionBackendCore"]
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
        "SemanticVersionBackendFoundation",
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "SemanticVersionTests",
      dependencies: [
        "SemanticVersion",
        "SemanticVersionBackendFoundation",
        "SemanticVersionBackendStringProcessing",
        "SemanticVersionMacro",
        "SemanticVersionMacroPlugin",
        .product(name: "MacroTesting", package: "swift-macro-testing")
      ]
    )
  ]
)
