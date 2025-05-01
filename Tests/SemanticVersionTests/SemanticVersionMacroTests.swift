import MacroTesting
import SemanticVersion
import SemanticVersionMacro
import SemanticVersionMacroPlugin
import Testing

@Suite(.macros(["SemanticVersion": SemanticVersionMacro.self]))
struct SemanticVersionMacroTests {
  
  @Test(
    arguments: [
      ("0.0.4", #"major: 0, minor: 0, patch: 4, prerelease: [], build: nil"#),
      ("1.2.3", #"major: 1, minor: 2, patch: 3, prerelease: [], build: nil"#),
      ("10.20.30", #"major: 10, minor: 20, patch: 30, prerelease: [], build: nil"#),
      ("1.1.2-prerelease+meta", #"major: 1, minor: 1, patch: 2, prerelease: [_Prerelease.alphanumeric("prerelease")], build: "meta""#),
      ("1.1.2+meta", #"major: 1, minor: 1, patch: 2, prerelease: [], build: "meta""#),
      ("1.1.2+meta-valid", #"major: 1, minor: 1, patch: 2, prerelease: [], build: "meta-valid""#),
      ("1.0.0-alpha", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha")], build: nil"#),
      ("1.0.0-beta", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("beta")], build: nil"#),
      ("1.0.0-alpha.beta", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha"), _Prerelease.alphanumeric("beta")], build: nil"#),
      ("1.0.0-alpha.beta.1", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha"), _Prerelease.alphanumeric("beta"), _Prerelease.numeric(1)], build: nil"#),
      ("1.0.0-alpha.1", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha"), _Prerelease.numeric(1)], build: nil"#),
      ("1.0.0-alpha0.valid", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha0"), _Prerelease.alphanumeric("valid")], build: nil"#),
      ("1.0.0-alpha.0valid", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha"), _Prerelease.alphanumeric("0valid")], build: nil"#),
      ("1.0.0-alpha-a.b-c-somethinglong+build.1-aef.1-its-okay", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha-a"), _Prerelease.alphanumeric("b-c-somethinglong")], build: "build.1-aef.1-its-okay""#),
      ("1.0.0-rc.1+build.1", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("rc"), _Prerelease.numeric(1)], build: "build.1""#),
      ("2.0.0-rc.1+build.123", #"major: 2, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("rc"), _Prerelease.numeric(1)], build: "build.123""#),
      ("1.2.3-beta", #"major: 1, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("beta")], build: nil"#),
      ("10.2.3-DEV-SNAPSHOT", #"major: 10, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("DEV-SNAPSHOT")], build: nil"#),
      ("1.2.3-SNAPSHOT-123", #"major: 1, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("SNAPSHOT-123")], build: nil"#),
      ("1.0.0", #"major: 1, minor: 0, patch: 0, prerelease: [], build: nil"#),
      ("2.0.0", #"major: 2, minor: 0, patch: 0, prerelease: [], build: nil"#),
      ("1.1.7", #"major: 1, minor: 1, patch: 7, prerelease: [], build: nil"#),
      ("2.0.0+build.1848", #"major: 2, minor: 0, patch: 0, prerelease: [], build: "build.1848""#),
      ("2.0.1-alpha.1227", #"major: 2, minor: 0, patch: 1, prerelease: [_Prerelease.alphanumeric("alpha"), _Prerelease.numeric(1227)], build: nil"#),
      ("1.0.0-alpha+beta", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("alpha")], build: "beta""#),
      ("1.2.3----RC-SNAPSHOT.12.9.1--.12+788", #"major: 1, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("---RC-SNAPSHOT"), _Prerelease.numeric(12), _Prerelease.numeric(9), _Prerelease.alphanumeric("1--"), _Prerelease.numeric(12)], build: "788""#),
      ("1.2.3----R-S.12.9.1--.12+meta", #"major: 1, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("---R-S"), _Prerelease.numeric(12), _Prerelease.numeric(9), _Prerelease.alphanumeric("1--"), _Prerelease.numeric(12)], build: "meta""#),
      ("1.2.3----RC-SNAPSHOT.12.9.1--.12", #"major: 1, minor: 2, patch: 3, prerelease: [_Prerelease.alphanumeric("---RC-SNAPSHOT"), _Prerelease.numeric(12), _Prerelease.numeric(9), _Prerelease.alphanumeric("1--"), _Prerelease.numeric(12)], build: nil"#),
      ("1.0.0+0.build.1-rc.10000aaa-kk-0.1", #"major: 1, minor: 0, patch: 0, prerelease: [], build: "0.build.1-rc.10000aaa-kk-0.1""#),
      ("1.0.0-0A.is.legal", #"major: 1, minor: 0, patch: 0, prerelease: [_Prerelease.alphanumeric("0A"), _Prerelease.alphanumeric("is"), _Prerelease.alphanumeric("legal")], build: nil"#)
    ]
  )
  func testValidVersion(_ pair: (string: String, expandedString: String)) {
    assertMacro {
      """
      #SemanticVersion("\(pair.string)")
      """
    } expansion: {
      """
      SemanticVersion._unchecked(\(pair.expandedString))
      """
    }
  }
  
  @Test
  func testInvalidVersion() {
    assertMacro {
      """
      #SemanticVersion("1")
      """
    } diagnostics: {
      """
      #SemanticVersion("1")
      ┬────────────────────
      ╰─ 🛑 Invalid semantic version string: "1"
      """
    }
  }
  
  @Test
  func testInvalidArgument() {
    assertMacro {
      """
      #SemanticVersion(1)
      """
    } diagnostics: {
      """
      #SemanticVersion(1)
      ┬──────────────────
      ╰─ 🛑 Argument must be a string literal
      """
    }
  }
}
