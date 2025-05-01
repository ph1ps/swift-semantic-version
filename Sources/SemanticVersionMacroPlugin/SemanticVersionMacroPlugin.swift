import SemanticVersionBackendFoundation
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
    var message: String { "Invalid semantic version string: \"\(string)\"" }
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
    
    guard let version = parse(foundation: literalSegment.content.text)
    else { throw DiagnosticsError(diagnostics: [.init(node: node, message: InvalidVersionDiagnostic(string: literalSegment.content.text))]) }
    
    let argumentList = LabeledExprListSyntax {
      LabeledExprSyntax(
        label: .identifier("major"),
        colon: .colonToken(),
        expression: IntegerLiteralExprSyntax(integerLiteral: Int(version.0))
      )
      LabeledExprSyntax(
        label: .identifier("minor"),
        colon: .colonToken(),
        expression: IntegerLiteralExprSyntax(integerLiteral: Int(version.1))
      )
      LabeledExprSyntax(
        label: .identifier("patch"),
        colon: .colonToken(),
        expression: IntegerLiteralExprSyntax(integerLiteral: Int(version.2))
      )
      LabeledExprSyntax(
        label: .identifier("prerelease"),
        colon: .colonToken(),
        expression: ArrayExprSyntax {
          for prerelease in version.3 {
            switch prerelease {
            case .alphanumeric(let string):
              ArrayElementSyntax(
                expression: FunctionCallExprSyntax(
                  calledExpression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("_Prerelease")), declName: DeclReferenceExprSyntax(baseName: .identifier("alphanumeric"))),
                  leftParen: .leftParenToken(),
                  arguments: [LabeledExprSyntax(expression: StringLiteralExprSyntax(content: string))],
                  rightParen: .rightParenToken()
                )
              )
            case .numeric(let uInt):
              ArrayElementSyntax(
                expression: FunctionCallExprSyntax(
                  calledExpression: MemberAccessExprSyntax(base: DeclReferenceExprSyntax(baseName: .identifier("_Prerelease")), declName: DeclReferenceExprSyntax(baseName: .identifier("numeric"))),
                  leftParen: .leftParenToken(),
                  arguments: [LabeledExprSyntax(expression: IntegerLiteralExprSyntax(Int(uInt)))],
                  rightParen: .rightParenToken()
                )
              )
            }
          }
        }
      )
      LabeledExprSyntax(
        label: .identifier("build"),
        colon: .colonToken(),
        expression: version.4.map { ExprSyntax(StringLiteralExprSyntax(content: $0)) } ?? ExprSyntax(NilLiteralExprSyntax())
      )
    }
    
    let functionCallExpr = FunctionCallExprSyntax(
      calledExpression: MemberAccessExprSyntax(
        base: DeclReferenceExprSyntax(baseName: .identifier("SemanticVersion")),
        name: .identifier("_unchecked")
      ),
      leftParen: .leftParenToken(),
      arguments: argumentList,
      rightParen: .rightParenToken(),
    )
    
    return ExprSyntax(functionCallExpr)
  }
}

@main
struct SemanticVersionMacroPlugin: CompilerPlugin {
  var providingMacros: [Macro.Type] = [SemanticVersionMacro.self]
}
