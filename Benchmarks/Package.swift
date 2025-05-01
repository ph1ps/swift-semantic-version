// swift-tools-version: 6.1
import PackageDescription

let package = Package(
  name: "swift-semantic-version-benchmarks",
  platforms: [.macOS(.v13)],
  dependencies: [
    .package(path: "..", traits: ["FoundationBackend", "StringProcessingBackend"]),
    .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.4.0")
  ],
  targets: [
    .executableTarget(
      name: "ParseBenchmark",
      dependencies: [
        .product(name: "Benchmark", package: "package-benchmark"),
        .product(name: "SemanticVersion", package: "swift-semantic-version")
      ],
      path: "Benchmarks/ParseBenchmark",
      plugins: [
        .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
      ]
    )
  ]
)
