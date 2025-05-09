# Semantic Version

A fast, spec-compliant semantic versioning library for Swift.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fph1ps%2Fswift-semantic-version%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ph1ps/swift-semantic-version)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fph1ps%2Fswift-semantic-version%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ph1ps/swift-semantic-version)

## Details

This library provides a lightweight and efficient implementation of [Semantic Versioning 2.0.0](https://semver.org/) in Swift.  
It offers a structured `SemanticVersion` type for representing versions with:

- `major`: Major version component (e.g., `1` in `1.2.3`).
- `minor`: Minor version component (e.g., `2` in `1.2.3`).
- `patch`: Patch version component (e.g., `3` in `1.2.3`).
- `prerelease`: Optional prerelease identifiers (e.g., `["alpha", "1"]` in `1.2.3-alpha.1`).
- `build`: Optional build metadata (e.g., `"build.5"` in `1.2.3+build.5`).

Parsing, comparison, and validation are fully compliant with the [Semantic Versioning 2.0.0 specification](https://semver.org/).

### Runtime Parsing

You can parse a version string at runtime using the failable initializer:

```swift
let version = SemanticVersion(versionString) // -> Optional<SemanticVersion>
```

If the string is not a valid semantic version, the initializer will return `nil`.

### Compile-Time Parsing

This library also provides a macro for compile-time safe parsing of semantic versions:

```swift
let version = #SemanticVersion("1.2.3-alpha.1+build.5") // -> SemanticVersion
```

If the provided string is invalid, a compile-time error will be produced.  
This ensures that all semantic versions used in your code are guaranteed to be valid at build time.

To use the macro:

1. Add `SemanticVersionMacro` as a dependency in your `Package.swift`:

```swift
.target(
  name: "YourTarget",
  dependencies: [
    .product(name: "SemanticVersionMacro", package: "swift-semantic-version")
  ]
)
```

2. Import `SemanticVersionMacro` in the file where you use the macro:

```swift
import SemanticVersionMacro
```

### Package Traits

This library uses Swift 6.1’s **package traits** feature to offer two selectable parsing backends:

- `FoundationBackend` (default): Uses Foundation's `NSRegularExpression` for parsing.
- `StringProcessingBackend`: Ues Swift's native `Regex` literals for parsing.

To configure which parsing backend is used, specify traits in your `Package.swift` dependency declaration:

```swift
.package(
  url: "https://github.com/ph1ps/swift-semantic-version",
  from: <current version>,
  traits: [
    "StringProcessingBackend"
  ]
)
```

#### Choosing the parsing backend

- **Performance**: `FoundationBackend` generally provides faster parsing performance (see [Benchmarks](#benchmarks)), while `StringProcessingBackend` is slightly slower.
- **Binary Size**: `FoundationBackend` has a big impact on binary size for platforms where `Foundation` is statically linked like `Musl`, `Android` or `WASM`. `StringProcessingBackend` on the other hand uses a pure Swift Standard Library implementation, which means no impact on binary size.
- **Availability**: The different traits have different platform availabilities due to their implementation details, which might be important to you, if you want to increase platform coverage
  - `FoundationBackend`: Requires `iOS 8.0`, `iPadOS 8.0`, `macOS 10.15`, `macCatalyst 13.1`, `tvOS 9.0`, `watchOS 2.0`, `visionOS 1.0`
  - `StringProcessingBackend`: Requires `iOS 16.0`, `iPadOS 16.0`, `macOS 13.0`, `macCatalyst 16.0`, `tvOS 16.0`, `watchOS 9.0`, `visionOS 1.0`

## Benchmarks

Performance benchmarks were conducted to compare the two available parsing backends: `FoundationBackend` and `StringProcessingBackend`.

The benchmarks use a set of 30 valid and 40 invalid semantic version strings, based on a variety of real-world examples and edge cases.  
Each benchmark measures the time taken to parse all provided versions repeatedly under scaled iterations.

The following parsing paths were benchmarked:
- Parsing invalid versions with `Foundation`
- Parsing valid versions with `Foundation`
- Parsing invalid versions with `StringProcessing`
- Parsing valid versions with `StringProcessing`

**Time (total CPU)**
| Test                                           | p0  | p25 | p50 | p75 | p90 | p99 | p100 | Samples |
|------------------------------------------------|-----|-----|-----|-----|-----|-----|------|---------|
| InitBenchmark:Foundation invalid (μs) *        |  56 |  57 |  57 |  57 |  58 |  69 |  234 |   9653  |
| InitBenchmark:Foundation valid (μs) *          | 100 | 104 | 105 | 106 | 110 | 131 |  385 |   6415  |
| InitBenchmark:StringProcessing invalid (μs) *  | 162 | 164 | 164 | 165 | 166 | 186 |  364 |   4685  |
| InitBenchmark:StringProcessing valid (μs) *    |1219 |1227 |1231 |1237 |1246 |1401 | 2038 |    774  |
