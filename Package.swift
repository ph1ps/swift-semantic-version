// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "swift-semantic-version",
  products: [
    .library(name: "SemanticVersion", targets: ["SemanticVersion"]),
  ],
  traits: [
    "Foundation",
    "StringProcessing",
    .default(enabledTraits: ["Foundation"]),
  ],
  targets: [
    .target(
      name: "SemanticVersion",
    ),
    .testTarget(
      name: "SemanticVersionTests",
      dependencies: ["SemanticVersion"]
    )
  ]
)
