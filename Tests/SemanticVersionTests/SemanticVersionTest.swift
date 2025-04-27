import Testing
@testable @_spi(Internal) import SemanticVersion

#if FoundationInit
@Test(
  arguments: [
    ("0.0.4", SemanticVersion(major: 0, minor: 0, patch: 4, prerelease: [], build: nil)),
    ("1.2.3", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [], build: nil)),
    ("10.20.30", SemanticVersion(major: 10, minor: 20, patch: 30, prerelease: [], build: nil)),
    ("1.1.2-prerelease+meta", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [.alphanumeric("prerelease")], build: "meta")),
    ("1.1.2+meta", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [], build: "meta")),
    ("1.1.2+meta-valid", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [], build: "meta-valid")),
    ("1.0.0-alpha", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: nil)),
    ("1.0.0-beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("beta")], build: nil)),
    ("1.0.0-alpha.beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta")], build: nil)),
    ("1.0.0-alpha.beta.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta"), .numeric(1)], build: nil)),
    ("1.0.0-alpha.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: nil)),
    ("1.0.0-alpha0.valid", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha0"), .alphanumeric("valid")], build: nil)),
    ("1.0.0-alpha.0valid", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("0valid")], build: nil)),
    ("1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha-a"), .alphanumeric("b-c-somethinglong")], build: "build.1-aef.1-its-okay")),
    ("1.0.0-rc.1+build.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: "build.1")),
    ("2.0.0-rc.1+build.123", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: "build.123")),
    ("1.2.3-beta", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("beta")], build: nil)),
    ("10.2.3-DEV-SNAPSHOT", SemanticVersion(major: 10, minor: 2, patch: 3, prerelease: [.alphanumeric("DEV-SNAPSHOT")], build: nil)),
    ("1.2.3-SNAPSHOT-123", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("SNAPSHOT-123")], build: nil)),
    ("1.0.0", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: nil)),
    ("2.0.0", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: nil)),
    ("1.1.7", SemanticVersion(major: 1, minor: 1, patch: 7, prerelease: [], build: nil)),
    ("2.0.0+build.1848", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: "build.1848")),
    ("2.0.1-alpha.1227", SemanticVersion(major: 2, minor: 0, patch: 1, prerelease: [.alphanumeric("alpha"), .numeric(1227)], build: nil)),
    ("1.0.0-alpha+beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: "beta")),
    ("1.2.3----RC-SNAPSHOT.12.9.1--.12+788", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---RC-SNAPSHOT"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: "788")),
    ("1.2.3----R-S.12.9.1--.12+meta", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---R-S"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: "meta")),
    ("1.2.3----RC-SNAPSHOT.12.9.1--.12", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---RC-SNAPSHOT"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: nil)),
    ("1.0.0+0.build.1-rc.10000aaa-kk-0.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: "0.build.1-rc.10000aaa-kk-0.1")),
    ("1.0.0-0A.is.legal", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("0A"), .alphanumeric("is"), .alphanumeric("legal")], build: nil))
  ]
)
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
func testValidFoundation(_ pair: (string: String, version: SemanticVersion)) {
  #expect(SemanticVersion(foundation: pair.string) == pair.version)
}

@Test(
  arguments: [
    "1",
    "1.2",
    "1.2.3-0123",
    "1.2.3-0123.0123",
    "1.1.2+.123",
    "+invalid",
    "-invalid",
    "-invalid+invalid",
    "-invalid.01",
    "alpha",
    "alpha.beta",
    "alpha.beta.1",
    "alpha.1",
    "alpha+beta",
    "alpha_beta",
    "alpha.",
    "alpha..",
    "beta",
    "1.0.0-alpha_beta",
    "-alpha.",
    "1.0.0-alpha..",
    "1.0.0-alpha..1",
    "1.0.0-alpha...1",
    "1.0.0-alpha....1",
    "1.0.0-alpha.....1",
    "1.0.0-alpha......1",
    "1.0.0-alpha.......1",
    "01.1.1",
    "1.01.1",
    "1.1.01",
    "1.2",
    "1.2.3.DEV",
    "1.2-SNAPSHOT",
    "1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788",
    "1.2-RC-SNAPSHOT",
    "-1.0.3-gamma+b7718",
    "+justmeta",
    "9.8.7+meta+meta",
    "9.8.7-whatever+meta+meta"
  ]
)
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
func testInvalidFoundation(_ string: String) {
  #expect(SemanticVersion(foundation: string) == nil)
}
#endif

#if StringProcessingInit
@Test(
  arguments: [
    ("0.0.4", SemanticVersion(major: 0, minor: 0, patch: 4, prerelease: [], build: nil)),
    ("1.2.3", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [], build: nil)),
    ("10.20.30", SemanticVersion(major: 10, minor: 20, patch: 30, prerelease: [], build: nil)),
    ("1.1.2-prerelease+meta", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [.alphanumeric("prerelease")], build: "meta")),
    ("1.1.2+meta", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [], build: "meta")),
    ("1.1.2+meta-valid", SemanticVersion(major: 1, minor: 1, patch: 2, prerelease: [], build: "meta-valid")),
    ("1.0.0-alpha", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: nil)),
    ("1.0.0-beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("beta")], build: nil)),
    ("1.0.0-alpha.beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta")], build: nil)),
    ("1.0.0-alpha.beta.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta"), .numeric(1)], build: nil)),
    ("1.0.0-alpha.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: nil)),
    ("1.0.0-alpha0.valid", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha0"), .alphanumeric("valid")], build: nil)),
    ("1.0.0-alpha.0valid", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("0valid")], build: nil)),
    ("1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha-a"), .alphanumeric("b-c-somethinglong")], build: "build.1-aef.1-its-okay")),
    ("1.0.0-rc.1+build.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: "build.1")),
    ("2.0.0-rc.1+build.123", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: "build.123")),
    ("1.2.3-beta", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("beta")], build: nil)),
    ("10.2.3-DEV-SNAPSHOT", SemanticVersion(major: 10, minor: 2, patch: 3, prerelease: [.alphanumeric("DEV-SNAPSHOT")], build: nil)),
    ("1.2.3-SNAPSHOT-123", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("SNAPSHOT-123")], build: nil)),
    ("1.0.0", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: nil)),
    ("2.0.0", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: nil)),
    ("1.1.7", SemanticVersion(major: 1, minor: 1, patch: 7, prerelease: [], build: nil)),
    ("2.0.0+build.1848", SemanticVersion(major: 2, minor: 0, patch: 0, prerelease: [], build: "build.1848")),
    ("2.0.1-alpha.1227", SemanticVersion(major: 2, minor: 0, patch: 1, prerelease: [.alphanumeric("alpha"), .numeric(1227)], build: nil)),
    ("1.0.0-alpha+beta", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: "beta")),
    ("1.2.3----RC-SNAPSHOT.12.9.1--.12+788", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---RC-SNAPSHOT"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: "788")),
    ("1.2.3----R-S.12.9.1--.12+meta", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---R-S"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: "meta")),
    ("1.2.3----RC-SNAPSHOT.12.9.1--.12", SemanticVersion(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("---RC-SNAPSHOT"), .numeric(12), .numeric(9), .alphanumeric("1--"), .numeric(12)], build: nil)),
    ("1.0.0+0.build.1-rc.10000aaa-kk-0.1", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: "0.build.1-rc.10000aaa-kk-0.1")),
    ("1.0.0-0A.is.legal", SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("0A"), .alphanumeric("is"), .alphanumeric("legal")], build: nil))
  ]
)
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
func testValidStringProcessing(_ pair: (string: String, version: SemanticVersion)) {
  #expect(SemanticVersion(stringProcessing: pair.string) == pair.version)
}

@Test(
  arguments: [
    "1",
    "1.2",
    "1.2.3-0123",
    "1.2.3-0123.0123",
    "1.1.2+.123",
    "+invalid",
    "-invalid",
    "-invalid+invalid",
    "-invalid.01",
    "alpha",
    "alpha.beta",
    "alpha.beta.1",
    "alpha.1",
    "alpha+beta",
    "alpha_beta",
    "alpha.",
    "alpha..",
    "beta",
    "1.0.0-alpha_beta",
    "-alpha.",
    "1.0.0-alpha..",
    "1.0.0-alpha..1",
    "1.0.0-alpha...1",
    "1.0.0-alpha....1",
    "1.0.0-alpha.....1",
    "1.0.0-alpha......1",
    "1.0.0-alpha.......1",
    "01.1.1",
    "1.01.1",
    "1.1.01",
    "1.2",
    "1.2.3.DEV",
    "1.2-SNAPSHOT",
    "1.2.31.2.3----RC-SNAPSHOT.12.09.1--..12+788",
    "1.2-RC-SNAPSHOT",
    "-1.0.3-gamma+b7718",
    "+justmeta",
    "9.8.7+meta+meta",
    "9.8.7-whatever+meta+meta"
  ]
)
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
func testInvalidStringProcessing(_ string: String) {
  #expect(SemanticVersion(stringProcessing: string) == nil)
}
#endif

@Test
@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
func testComparable() {
  let versions = [
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha")], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("alpha"), .alphanumeric("beta")], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("beta")], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(2)], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("beta"), .numeric(11)], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [.alphanumeric("rc"), .numeric(1)], build: nil),
    SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: [], build: nil),
  ]
  #expect(versions == versions.sorted())
}
