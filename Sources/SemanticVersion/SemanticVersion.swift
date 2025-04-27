/// A structure representing a [Semantic Versioning 2.0.0](https://semver.org/) version number.
///
/// # Overview
///
/// `SemanticVersion` models a version consisting of several components:
///
/// - **Major version**: An unsigned integer, such as `1` in `1.2.3`.
/// - **Minor version**: An unsigned integer, such as `2` in `1.2.3`.
/// - **Patch version**: An unsigned integer, such as `3` in `1.2.3`.
/// - **Prerelease identifiers**: An optional array of strings representing the prerelease information.
/// - **Build metadata**: An optional string representing the build information.
///
/// Parsing, comparison, and validation are fully compliant with the [Semantic Versioning 2.0.0](https://semver.org/) specification.
public struct SemanticVersion: Sendable, Equatable, Comparable, Hashable, Encodable {
  
  public enum _Prerelease: Sendable, Equatable, Hashable {
    case alphanumeric(Substring)
    case numeric(UInt)
    
    var description: String {
      switch self {
      case .alphanumeric(let substring):
        String(substring)
      case .numeric(let integer):
        String(integer)
      }
    }
  }
  
  /// The major version component.
  ///
  /// Example: In `1.2.3`, the major version is `1`.
  public let major: UInt
  
  /// The minor version component.
  ///
  /// Example: In `1.2.3`, the minor version is `2`.
  public let minor: UInt
  
  /// The patch version component.
  ///
  /// Example: In `1.2.3`, the patch version is `3`.
  public let patch: UInt
  
  public let _prerelease: [_Prerelease]
  public let _build: Substring?
  
  /// The prerelease identifiers for the version, if any.
  ///
  /// Examples:
  /// - For `1.2.3-alpha.1`, `prerelease` is `["alpha", "1"]`.
  /// - For `1.2.3`, `prerelease` is an empty array.
  public var prerelease: [String] {
    _prerelease.map { $0.description }
  }
  
  /// The build metadata for the version, if any.
  ///
  /// Examples:
  /// - For `1.2.3+build.5`, `build` is `"build.5"`.
  /// - For `1.2.3`, `build` is `nil`.
  public var build: String? {
    _build.map { String($0) }
  }
  
  init(major: UInt, minor: UInt, patch: UInt, prerelease: [_Prerelease], build: Substring?) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self._prerelease = prerelease
    self._build = build
  }
  
  /// A string representation of the complete semantic version.
  ///
  /// The format includes major, minor, and patch versions, and may include
  /// prerelease identifiers and build metadata if present.
  ///
  /// Examples:
  /// - `"1.2.3"`
  /// - `"1.2.3-alpha.1"`
  /// - `"1.2.3+build.5"`
  public var description: String {
    var description = "\(major).\(minor).\(patch)"
    if !_prerelease.isEmpty {
      description += "-\(prerelease.lazy.map { $0.description }.joined(separator: "."))"
    }
    if let build {
      description += "+\(build)"
    }
    return description
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(major)
    hasher.combine(minor)
    hasher.combine(patch)
    hasher.combine(_prerelease)
    hasher.combine(_build)
  }
  
  public static func ==(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs._prerelease.elementsEqual(rhs._prerelease) && lhs._build == rhs._build
  }
  
  public static func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
    
    guard lhs.major == rhs.major
    else { return lhs.major < rhs.major }
    
    guard lhs.minor == rhs.minor
    else { return lhs.minor < rhs.minor }
    
    guard lhs.patch == rhs.patch
    else { return lhs.patch < rhs.patch }
    
    if lhs._prerelease.isEmpty != rhs._prerelease.isEmpty {
      return rhs._prerelease.isEmpty
    }
    
    for (lhs, rhs) in zip(lhs._prerelease, rhs._prerelease) {
      guard lhs != rhs
      else { continue }
      
      switch (lhs, rhs) {
      case (.numeric, .alphanumeric):
        return true
      case (.alphanumeric, .numeric):
        return false
      case (.numeric(let lhs), .numeric(let rhs)):
        return lhs < rhs
      case (.alphanumeric(let lhs), .alphanumeric(let rhs)):
        return lhs.lexicographicallyPrecedes(rhs)
      }
    }
    
    return lhs._prerelease.count < rhs._prerelease.count
  }
  
  public static func _unchecked(major: UInt, minor: UInt, patch: UInt, prerelease: [_Prerelease], build: Substring?) -> SemanticVersion {
    self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, build: build)
  }
}

#if FoundationInit
import Foundation

let foundationRegex = try? NSRegularExpression(pattern: #"^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$"#)

extension SemanticVersion {
  
  @_spi(Internal)
  public init?(foundation string: String) {
    guard
      let foundationRegex,
      let match = foundationRegex.firstMatch(in: string, range: .init(string.startIndex..., in: string)),
      let majorRange = Range(match.range(at: 1), in: string),
      let minorRange = Range(match.range(at: 2), in: string),
      let patchRange = Range(match.range(at: 3), in: string),
      let major = UInt(string[majorRange]),
      let minor = UInt(string[minorRange]),
      let patch = UInt(string[patchRange])
    else { return nil }
    let prerelease = Range(match.range(at: 4), in: string).map {
      SubstringSplitSequence(base: string[$0]).map {
        if let number = UInt($0) {
          return _Prerelease.numeric(number)
        } else {
          return _Prerelease.alphanumeric($0)
        }
      }
    }
    let build = Range(match.range(at: 5), in: string).map { string[$0] }
    self = .init(major: major, minor: minor, patch: patch, prerelease: prerelease ?? [], build: build)
  }
}
#endif

#if StringProcessingInit
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
nonisolated(unsafe) let stringProcessingRegex = /^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/

@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension SemanticVersion {
  
  @_spi(Internal)
  public init?(stringProcessing string: String) {
    guard
      let match = try? stringProcessingRegex.firstMatch(in: string),
      let major = UInt(match.output.major),
      let minor = UInt(match.output.minor),
      let patch = UInt(match.output.patch)
    else { return nil }
    let prerelease = match.output.prerelease.map {
      SubstringSplitSequence(base: $0).map {
        if let number = UInt($0) {
          return _Prerelease.numeric(number)
        } else {
          return _Prerelease.alphanumeric($0)
        }
      }
    }
    self = .init(major: major, minor: minor, patch: patch, prerelease: prerelease ?? [], build: match.output.buildmetadata)
  }
}
#endif

#if FoundationInit
extension SemanticVersion: Decodable {
  
  /// Initializes a `SemanticVersion` by parsing a version string.
  ///
  /// Uses Foundation's regular expression matching.
  ///
  /// - Parameter string: A string representing a semantic version (e.g., `"1.2.3"`, `"1.2.3-alpha.1"`, `"1.2.3+build.5"`).
  public init?(_ string: String) {
    self.init(foundation: string)
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    if let version = SemanticVersion(string) {
      self = version
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version: \(string)")
    }
  }
}
#elseif StringProcessingInit
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension SemanticVersion: Decodable {
  
  /// Initializes a `SemanticVersion` by parsing a version string.
  ///
  /// Uses Swift's regex literal matching.
  ///
  /// - Parameter string: A string representing a semantic version (e.g., `"1.2.3"`, `"1.2.3-alpha.1"`, `"1.2.3+build.5"`).
  public init?(_ string: String) {
    self.init(stringProcessing: string)
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    if let version = SemanticVersion(string) {
      self = version
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version: \(string)")
    }
  }
}
#endif

struct SubstringSplitSequence: Sequence {
  
  let base: Substring
  
  func makeIterator() -> Iterator {
    return .init(base: base, index: base.startIndex)
  }
  
  struct Iterator: IteratorProtocol {
    
    let base: Substring
    var index: Substring.Index
    
    mutating func next() -> Substring? {
      let startIndex = index
      while index < base.endIndex && base[index] != "." {
        index = base.index(after: index)
      }
      if startIndex == base.endIndex {
        return nil
      } else {
        let substring = base[startIndex..<index]
        if index != base.endIndex {
          index = base.index(after: index)
        }
        return substring
      }
    }
  }
}
