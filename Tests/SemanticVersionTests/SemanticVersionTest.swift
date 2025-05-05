import _SemanticVersionBackendCore
@_spi(Internal) import _SemanticVersionBackendFoundation
@_spi(Internal) import _SemanticVersionBackendStringProcessing
import Foundation
@testable import SemanticVersion
import Testing

extension SemanticVersion {
  init?(unmapped: (UInt, UInt, UInt, [_Prerelease], String?)?) {
    if let unmapped {
      self.init(major: unmapped.0, minor: unmapped.1, patch: unmapped.2, prerelease: unmapped.3, build: unmapped.4)
    } else {
      return nil
    }
  }
}

@Suite
struct SemanticVersionTests {
  
  @Test(arguments: Array(zip([String].validVersions, [SemanticVersion].validParsedVersions)))
  func testValidFoundation(_ pair: (string: String, version: SemanticVersion)) {
    #expect(SemanticVersion(unmapped: parse(foundation: pair.string)) == pair.version)
  }
  
  @Test(arguments: [String].invalidVersions)
  func testInvalidFoundation(_ string: String) {
    #expect(SemanticVersion(unmapped: parse(foundation: string)) == nil)
  }
  
  @Test(arguments: Array(zip([String].validVersions, [SemanticVersion].validParsedVersions)))
  @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  func testValidStringProcessing(_ pair: (string: String, version: SemanticVersion)) {
    #expect(SemanticVersion(unmapped: parse(stringProcessing: pair.string)) == pair.version)
  }
  
  @Test(arguments: [String].invalidVersions)
  @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  func testInvalidStringProcessing(_ string: String) {
    #expect(SemanticVersion(unmapped: parse(stringProcessing: string)) == nil)
  }
  
  @Test(arguments: Array(zip([String].validVersions, [SemanticVersion].validParsedVersions)))
  func testDescription(_ pair: (string: String, version: SemanticVersion)) throws {
    #expect(pair.string == pair.version.description)
  }
  
  @Test
  func testEquatableIgnoringBuildMetadata() {
    #expect(SemanticVersion(major: 0, minor: 0, patch: 0, prerelease: [], build: "build1") == SemanticVersion(major: 0, minor: 0, patch: 0, prerelease: [], build: "build2"))
  }
  
  @Test
  func testComparable() {
    let version1 = SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: nil)
    let version2 = SemanticVersion(major: 1, minor: 1, patch: 0, prerelease: [], build: nil)
    let version3 = SemanticVersion(major: 1, minor: 1, patch: 1, prerelease: [], build: nil)
    let version4 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.numeric(1)], build: nil)
    let version5 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: nil)
    let version6 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: nil)
    let version7 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta")], build: nil)
    let version8 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta")], build: nil)
    let version9 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(2)], build: nil)
    let version10 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(11)], build: nil)
    let version11 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: nil)
    let version12 = SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: nil)
    #expect(version1 < version2)
    #expect(version2 < version3)
    #expect(version3 < version4)
    #expect(version4 < version5)
    #expect(!(version5 < version4))
    #expect(version5 < version6)
    #expect(version6 < version7)
    #expect(version7 < version8)
    #expect(version8 < version9)
    #expect(version9 < version10)
    #expect(version10 < version11)
    #expect(version11 < version12)
  }
  
  #if FoundationBackend || StringProcessingBackend
  @Test(arguments: [SemanticVersion].validParsedVersions)
  func testCodable(_ originalVersion: SemanticVersion) throws {
    let data = try JSONEncoder().encode(originalVersion)
    let parsedVersion = try JSONDecoder().decode(SemanticVersion.self, from: data)
    #expect(originalVersion == parsedVersion)
  }
  
  @Test(arguments: [String].invalidVersions)
  func testDecodableInvalid(_ invalidVersion: String) {
    let error = #expect(throws: DecodingError.self) {
      try JSONDecoder().decode([SemanticVersion].self, from: Data("[\"\(invalidVersion)\"]".utf8))
    }
    #expect(error.debugDescription.contains("Invalid semantic version string"))
  }
  #endif
}
