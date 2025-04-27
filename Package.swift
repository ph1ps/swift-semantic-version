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
    "FoundationInit",
    "StringProcessingInit",
    .default(enabledTraits: ["FoundationInit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"602.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.2")
  ],
  targets: [
    .target(
      name: "SemanticVersion",
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
        "SemanticVersion",
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
      ]
    ),
    .testTarget(
      name: "SemanticVersionMacroTests",
      dependencies: [
        "SemanticVersionMacro",
        .product(name: "MacroTesting", package: "swift-macro-testing")
      ]
    ),
    .testTarget(
      name: "SemanticVersionTests",
      dependencies: ["SemanticVersion"]
    )
  ]
)
