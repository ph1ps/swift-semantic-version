import SemanticVersion
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct SemanticVersionMacro: ExpressionMacro {
  
  struct InvalidArgumentDiagnostic: DiagnosticMessage {
    let diagnosticID = MessageID(domain: "SemanticVersionMacro", id: "InvalidArgumentDiagnostic")
    let severity = DiagnosticSeverity.error
    let message = "Argument must be a string literal"
  }
  
  struct InvalidVersionDiagnostic: DiagnosticMessage {
    let string: String
    let diagnosticID = MessageID(domain: "SemanticVersionMacro", id: "InvalidVersionDiagnostic")
    let severity = DiagnosticSeverity.error
    var message: String {
      """
      Invalid semantic version string: "\(string)".
      The input must follow the Semantic Versioning 2.0.0 specification (https://semver.org/).
      """
    }
  }
  
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    
    guard
      let argument = node.arguments.first?.expression,
      let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
      segments.count == 1,
      case .stringSegment(let literalSegment)? = segments.first
    else {
      throw DiagnosticsError(diagnostics: [.init(node: node, message: InvalidArgumentDiagnostic())])
    }
    
    guard let version = SemanticVersion(literalSegment.content.text)
    else { throw DiagnosticsError(diagnostics: [.init(node: node, message: InvalidVersionDiagnostic(string: literalSegment.content.text))]) }
    
    if let build = version._build {
      return "SemanticVersion._unchecked(major: \(raw: version.major), minor: \(raw: version.minor), patch: \(raw: version.patch), prerelease: \(raw: version._prerelease), build: \"\(raw: build)\")"
    } else {
      return "SemanticVersion._unchecked(major: \(raw: version.major), minor: \(raw: version.minor), patch: \(raw: version.patch), prerelease: \(raw: version._prerelease), build: nil)"
    }
  }
}

@main
struct SemanticVersionMacroPlugin: CompilerPlugin {
  var providingMacros: [Macro.Type] = [SemanticVersionMacro.self]
}
