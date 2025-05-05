@_exported import _SemanticVersionBackendCore
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
    
  /// The build metadata for the version, if any.
  ///
  /// Examples:
  /// - For `1.2.3+build.5`, `build` is `"build.5"`.
  /// - For `1.2.3`, `build` is `nil`.
  public let build: String?
  
  /// The prerelease identifiers for the version, if any.
  ///
  /// Examples:
  /// - For `1.2.3-alpha.1`, `prerelease` is `["alpha", "1"]`.
  /// - For `1.2.3`, `prerelease` is an empty array.
  public var prerelease: [String] {
    _prerelease.map {
      switch $0 {
      case .alphanumeric(let string): string
      case .numeric(let integer): String(integer)
      }
    }
  }
  
  let _prerelease: [_Prerelease]
  
  init(major: UInt, minor: UInt, patch: UInt, prerelease: [_Prerelease], build: String?) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self._prerelease = prerelease
    self.build = build
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
      description += "-\(prerelease.joined(separator: "."))"
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
  
  public static func ==(lhs: Self, rhs: Self) -> Bool {
    return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs._prerelease.elementsEqual(rhs._prerelease)
  }
  
  public static func <(lhs: Self, rhs: Self) -> Bool {
    
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
  
  public static func _unchecked(major: UInt, minor: UInt, patch: UInt, prerelease: [_Prerelease], build: String?) -> SemanticVersion {
    self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, build: build)
  }
}

#if FoundationBackend
@_spi(Internal) import _SemanticVersionBackendFoundation

extension SemanticVersion: Decodable {
  /// Initializes a `SemanticVersion` by parsing a version string.
  ///
  /// Uses Foundation's regular expression matching.
  ///
  /// - Parameter string: A string representing a semantic version (e.g., `"1.2.3"`, `"1.2.3-alpha.1"`, `"1.2.3+build.5"`).
  public init?(_ string: String) {
    if let result = parse(foundation: string) {
      self = .init(major: result.0, minor: result.1, patch: result.2, prerelease: result.3, build: result.4)
    } else {
      return nil
    }
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    if let version = SemanticVersion(string) {
      self = version
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version string: \"\(string)\"")
    }
  }
}
#elseif StringProcessingBackend
@_spi(Internal) import _SemanticVersionBackendStringProcessing

@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension SemanticVersion: Decodable {
  /// Initializes a `SemanticVersion` by parsing a version string.
  ///
  /// Uses Swift's regex literal matching.
  ///
  /// - Parameter string: A string representing a semantic version (e.g., `"1.2.3"`, `"1.2.3-alpha.1"`, `"1.2.3+build.5"`).
  public init?(_ string: String) {
    if let result = parse(stringProcessing: string) {
      self = .init(major: result.0, minor: result.1, patch: result.2, prerelease: result.3, build: result.4)
    } else {
      return nil
    }
  }
  
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    if let version = SemanticVersion(string) {
      self = version
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid semantic version string: \"\(string)\"")
    }
  }
}
#endif
