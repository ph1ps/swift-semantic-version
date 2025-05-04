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
    #expect(parse(foundation: string) == nil)
  }
  
  @Test(arguments: Array(zip([String].validVersions, [SemanticVersion].validParsedVersions)))
  @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  func testValidStringProcessing(_ pair: (string: String, version: SemanticVersion)) {
    #expect(SemanticVersion(unmapped: parse(stringProcessing: pair.string)) == pair.version)
  }
  
  @Test(arguments: [String].invalidVersions)
  @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
  func testInvalidStringProcessing(_ string: String) {
    #expect(parse(stringProcessing: string) == nil)
  }
  
  @Test(arguments: Array(zip([String].validVersions, [SemanticVersion].validParsedVersions)))
  func testDescription(_ pair: (string: String, version: SemanticVersion)) throws {
    #expect(pair.string == pair.version.description)
  }
  
  @Test
  func testComparable() {
    let versions = [
      SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: nil),
      SemanticVersion(major: 1, minor: 1, patch: 0, prerelease: [], build: nil),
      SemanticVersion(major: 1, minor: 1, patch: 1, prerelease: [], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta")], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta")], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(2)], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(11)], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: nil),
      SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: nil),
    ]
    #expect(versions == versions.sorted())
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
