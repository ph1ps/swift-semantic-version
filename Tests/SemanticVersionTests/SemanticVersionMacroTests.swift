import MacroTesting
@testable import SemanticVersion
import SemanticVersionMacro
import SemanticVersionMacroPlugin
import Testing

@Suite(.macros(["SemanticVersion": SemanticVersionMacro.self]))
struct SemanticVersionMacroTests {
  
  @Test(arguments: Array(zip([String].validVersions, [String].expandedVersions)))
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
  
  @Test
  func testMacroExpansion() {
    let version = #SemanticVersion("1.2.3-alpha.1+beta")
    #expect(version == .init(major: 1, minor: 2, patch: 3, prerelease: [.alphanumeric("alpha"), .numeric(1)], build: "beta"))
  }
}
